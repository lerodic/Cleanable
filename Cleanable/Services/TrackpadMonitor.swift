import AppKit
import Foundation

class TrackpadMonitor {
    weak var delegate: TrackpadMonitorDelegate?

    private static var eventMask: CGEventMask {
        let types: [CGEventType] = [
            .leftMouseDown, .leftMouseUp,
            .rightMouseDown, .rightMouseUp,
            .otherMouseDown, .otherMouseUp,
        ]
        return types.reduce(0) { $0 | (1 << $1.rawValue) }
    }

    private static let eventTapCallback: CGEventTapCallBack = { _, type, event, refcon in
        guard let refcon else { return Unmanaged.passUnretained(event) }
        let monitor = Unmanaged<TrackpadMonitor>
            .fromOpaque(refcon)
            .takeUnretainedValue()

        if monitor.areTapsDisabled(by: type) {
            CGEvent.tapEnable(tap: monitor.eventTap!, enable: true)
            return Unmanaged.passUnretained(event)
        }

        return monitor.handle(event: event, ofType: type)
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init() {
        if AXIsProcessTrusted() {
            startMonitoring()
        }
    }

    deinit {
        stopMonitoring()
    }

    func areTapsDisabled(by type: CGEventType) -> Bool {
        type == .tapDisabledByTimeout || type == .tapDisabledByUserInput
    }

    @discardableResult
    func handle(event: CGEvent, ofType type: CGEventType) -> Unmanaged<CGEvent>? {
        guard let nsEvent = NSEvent(cgEvent: event) else {
            return Unmanaged.passUnretained(event)
        }

        if delegate?.trackpadMonitor(self, shouldBlockEvent: nsEvent) == true {
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func startMonitoring() {
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: TrackpadMonitor.eventMask,
            callback: TrackpadMonitor.eventTapCallback,
            userInfo: UnsafeMutableRawPointer(
                Unmanaged.passUnretained(self).toOpaque()
            )
        )

        guard let eventTap else {
            return print("Failed to create trackpad event tap.")
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func stopMonitoring() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        runLoopSource = nil
        eventTap = nil
    }
}
