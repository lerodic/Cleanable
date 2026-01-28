import AppKit
@testable import Cleanable
import Foundation
import Testing

@Suite("KeyboardMonitor Tests")
struct KeyboardMonitorTests {
    class MockKeyboardMonitorDelegate: KeyboardMonitorDelegate {
        var shortcutDetectedCount = 0
        var lastDetectedShortcut: KeyboardShortcut?
        var shouldBlockEvent = false
        var blockedEventCount = 0
        
        func keyboardMonitor(_ monitor: KeyboardMonitor, didDetectShortcut shortcut: KeyboardShortcut) {
            shortcutDetectedCount += 1
            lastDetectedShortcut = shortcut
        }
        
        func keyboardMonitor(_ monitor: KeyboardMonitor, shouldBlockEvent event: NSEvent) -> Bool {
            if shouldBlockEvent {
                blockedEventCount += 1
            }
            
            return shouldBlockEvent
        }
    }
    
    @MainActor
    @Test(
        "Monitor initializes with correct shortcut",
        arguments: [
            KeyboardShortcut(keyCode: 1, modifierFlags: NSEvent.ModifierFlags.option.rawValue),
            KeyboardShortcut(
                keyCode: 12,
                modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
            )
        ]
    )
    func initializeMonitor(_ shortcut: KeyboardShortcut) {
        let monitor = KeyboardMonitor(shortcut: shortcut)
        let delegate = MockKeyboardMonitorDelegate()
        monitor.delegate = delegate
        
        #expect(delegate.shortcutDetectedCount == 0)
        #expect(monitor.currentShortcut == shortcut)
    }
    
    @MainActor
    @Test("Monitor can update shortcut", arguments: updateShortcutFixtures)
    func updateShortcut(_ testCase: UpdateShortcutCase) {
        let monitor = KeyboardMonitor(shortcut: testCase.initialShortcut)
        
        monitor.updateShortcut(testCase.newShortcut)
        
        #expect(monitor.currentShortcut == testCase.newShortcut)
    }
    
    @Test("Detects tap disabled by timeout")
    func detectTapDisabledByTimeout() {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        
        let isDisabled = monitor.areTapsDisabled(by: .tapDisabledByTimeout)
        
        #expect(isDisabled == true)
    }
    
    @Test("Detects tap disabled by user input")
    func detectTapDisabledByUserInput() {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        
        let isDisabled = monitor.areTapsDisabled(by: .tapDisabledByUserInput)
        
        #expect(isDisabled == true)
    }
    
    @Test("Does not detect regular key down event as disabled tap")
    func ignoreRegularKeyDownAsDisabledTap() {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        
        let isDisabled = monitor.areTapsDisabled(by: .keyDown)
        
        #expect(isDisabled == false)
    }
    
    @Test("Passes through key up events")
    func passThroughKeyUpEvents() {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        let delegate = MockKeyboardMonitorDelegate()
        monitor.delegate = delegate
        
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: 37, keyDown: false) else {
            Issue.record("Failed to create CGEvent")
            return
        }
        
        let result = monitor.handle(event: event, ofType: .keyUp)
        
        #expect(result != nil)
        #expect(delegate.shortcutDetectedCount == 0)
    }
    
    @MainActor
    @Test("Detects matching shortcut and notifies delegate", arguments: detectsMatchingShortcutFixtures)
    func detectsMatchingShortcut(_ testCase: DetectsMatchingShortcutCase) async {
        let monitor = KeyboardMonitor(shortcut: testCase.shortcut)
        let delegate = MockKeyboardMonitorDelegate()
        monitor.delegate = delegate
        
        let result = monitor.handle(event: testCase.event, ofType: .keyDown)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(result == nil)
        #expect(delegate.shortcutDetectedCount == 1)
        #expect(delegate.lastDetectedShortcut == testCase.shortcut)
    }
    
    @Test("Blocks events when delegate requests blocking", arguments: detectsMatchingShortcutFixtures)
    func blocksEventsWhenDelegateRequestsBlock(_ testCase: DetectsMatchingShortcutCase) {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        let delegate = MockKeyboardMonitorDelegate()
        delegate.shouldBlockEvent = true
        monitor.delegate = delegate
        
        let result = monitor.handle(event: testCase.event, ofType: .keyDown)
        
        #expect(result == nil)
        #expect(delegate.blockedEventCount == 1)
    }
    
    @Test("Should pass on events when delegate allows it", arguments: detectsMatchingShortcutFixtures)
    func passOnEventsWhenDelegateAllowsIt(_ testCase: DetectsMatchingShortcutCase) {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        let delegate = MockKeyboardMonitorDelegate()
        delegate.shouldBlockEvent = false
        monitor.delegate = delegate
        
        let result = monitor.handle(event: testCase.event, ofType: .keyDown)
        
        #expect(result != nil)
        #expect(delegate.blockedEventCount == 0)
    }
    
    @MainActor
    @Test("Handles key down events that don't resemble stored shortcut", arguments: detectsMatchingShortcutFixtures)
    func handleNonShortcutKeyDownEvents(_ testCase: DetectsMatchingShortcutCase) async {
        let monitor = KeyboardMonitor(shortcut: .defaultShortcut)
        let delegate = MockKeyboardMonitorDelegate()
        monitor.delegate = delegate
        
        monitor.handle(event: testCase.event, ofType: .keyDown)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(delegate.shortcutDetectedCount == 0)
    }
    
    @MainActor
    @Test("Updates shortcut and immediately recognizes it as such", arguments: updateShortcutAndRecognizeFixtures)
    func updateShortcutAndRecognize(_ testCase: UpdateShortcutAndRecognizeCase) async {
        let monitor = KeyboardMonitor(shortcut: testCase.initialShortcut)
        let delegate = MockKeyboardMonitorDelegate()
        monitor.delegate = delegate
        
        monitor.updateShortcut(testCase.newShortcut)
        
        let result = monitor.handle(event: testCase.event, ofType: .keyDown)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(result == nil)
        #expect(delegate.shortcutDetectedCount == 1)
        #expect(delegate.lastDetectedShortcut == testCase.newShortcut)
    }
}
