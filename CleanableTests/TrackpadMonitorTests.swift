import AppKit
@testable import Cleanable
import Foundation
import Testing

struct TrackpadMonitorTests {
    private func makeCGMouseEvent(type: CGEventType) -> CGEvent? {
        let button: CGMouseButton = switch type {
        case .leftMouseDown, .leftMouseUp: .left
        case .rightMouseDown, .rightMouseUp: .right
        default: .center
        }
        
        return CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: .zero,
            mouseButton: button
        )
    }
    
    class MockTrackpadMonitorDelegate: TrackpadMonitorDelegate {
        var shouldBlockEvent = false
        var blockedEventCount = 0
        var statusItemFrame: CGRect?
        var isStatusItemInteractive = false
        
        func trackpadMonitor(_ monitor: TrackpadMonitor, shouldBlockEvent event: NSEvent) -> Bool {
            if shouldBlockEvent {
                blockedEventCount += 1
            }
            
            return shouldBlockEvent
        }
        
        func trackpadMonitorStatusItemFrame(_ monitor: TrackpadMonitor) -> CGRect? {
            statusItemFrame
        }
        
        func trackpadMonitorIsStatusItemInteractive(_ monitor: TrackpadMonitor) -> Bool {
            isStatusItemInteractive
        }
    }
    
    @Test("Detects tap disabled by timeout")
    func detectTapDisabledByTimeout() {
        let monitor = TrackpadMonitor()
        
        let isDisabled = monitor.areTapsDisabled(by: .tapDisabledByTimeout)
        
        #expect(isDisabled == true)
    }
    
    @Test("Detects tap disabled by user input")
    func detectTapDisabledByUserInput() {
        let monitor = TrackpadMonitor()
        
        let isDisabled = monitor.areTapsDisabled(by: .tapDisabledByUserInput)
        
        #expect(isDisabled == true)
    }
    
    @Test("Passes through events when delegate allows it")
    func passesEventThroughWhenNotBlocked() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = false
        monitor.delegate = delegate
            
        let cgEvent = try #require(CGEvent(source: nil))
        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)
            
        #expect(result != nil)
        #expect(delegate.blockedEventCount == 0)
    }
        
    @Test("Blocks event when delegate requests it")
    func blocksEventWhenDelegateRequestsIt() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate

        let cgEvent = try #require(makeCGMouseEvent(type: .leftMouseDown))
        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)

        #expect(result == nil)
        #expect(delegate.blockedEventCount == 1)
    }

    @Test("Blocks all tracked event types when locked")
    func blocksAllTrackedEventTypes() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate

        let blockedTypes: [CGEventType] = [
            .leftMouseDown, .leftMouseUp,
            .rightMouseDown, .rightMouseUp,
            .otherMouseDown, .otherMouseUp,
        ]

        for type in blockedTypes {
            let cgEvent = try #require(makeCGMouseEvent(type: type))
            let result = monitor.handle(event: cgEvent, ofType: type)
            #expect(result == nil, "Expected event of type \(type) to be blocked")
        }

        #expect(delegate.blockedEventCount == blockedTypes.count)
    }
        
    @Test("Passes through event with no delegate set")
    func passesEventThroughWithNoDelegate() throws {
        let monitor = TrackpadMonitor()
            
        let cgEvent = try #require(CGEvent(source: nil))
        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)
            
        #expect(result != nil)
    }
        
    @Test("Increments blocked count on repeated events")
    func incrementsBlockedCountOnRepeatedEvents() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate

        for _ in 1 ... 5 {
            let cgEvent = try #require(makeCGMouseEvent(type: .leftMouseDown))
            monitor.handle(event: cgEvent, ofType: .leftMouseDown)
        }

        #expect(delegate.blockedEventCount == 5)
    }
    
    @Test("Passes through event when click is inside status item frame")
    func passesEventThroughInsideStatusItemFrame() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate
        
        let screenHeight = try #require(NSScreen.screens.first?.frame.height)
        let clickPosition = CGPoint(x: 50, y: screenHeight - 10)
        delegate.statusItemFrame = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        let cgEvent = try #require(
            CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseDown,
                mouseCursorPosition: clickPosition,
                mouseButton: .left
            )
        )
        
        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)
        
        #expect(result != nil)
        #expect(delegate.blockedEventCount == 0)
    }
    
    @Test("Blocks event when click is outside status item frame")
    func blocksEventWhenOutsideStatusItemFrame() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate

        let screenHeight = try #require(NSScreen.screens.first?.frame.height)
        let clickPosition = CGPoint(x: 50, y: screenHeight - 10)
        delegate.statusItemFrame = CGRect(x: 200, y: 0, width: 100, height: 30)

        let cgEvent = try #require(CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: clickPosition,
            mouseButton: .left
        ))

        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)

        #expect(result == nil)
        #expect(delegate.blockedEventCount == 1)
    }
    
    @Test("Passes through event when status item menu is open")
    func passesEventThroughWhenStatusItemMenuIsOpen() throws {
        let monitor = TrackpadMonitor()
        let delegate = MockTrackpadMonitorDelegate()
        delegate.shouldBlockEvent = true
        delegate.isStatusItemInteractive = true
        monitor.delegate = delegate

        let cgEvent = try #require(makeCGMouseEvent(type: .leftMouseDown))
        let result = monitor.handle(event: cgEvent, ofType: .leftMouseDown)

        #expect(result != nil)
        #expect(delegate.blockedEventCount == 0)
    }
}
