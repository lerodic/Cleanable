import AppKit
import Foundation

class KeyboardMonitor {
    weak var delegate: KeyboardMonitorDelegate?
    
    private static var eventMask: CGEventMask {
        return (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
    }
    
    private static let eventTapCallback: CGEventTapCallBack = { _, type, event, refcon in
        guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
        let monitor = Unmanaged<KeyboardMonitor>
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
    private(set) var currentShortcut: KeyboardShortcut
    
    init(shortcut: KeyboardShortcut) {
        currentShortcut = shortcut
        
        if AXIsProcessTrusted() {
            startMonitoring()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    func areTapsDisabled(by type: CGEventType) -> Bool {
        type == CGEventType.tapDisabledByTimeout || type == CGEventType.tapDisabledByUserInput
    }
    
    func updateShortcut(_ shortcut: KeyboardShortcut) {
        currentShortcut = shortcut
    }
    
    private func startMonitoring() {
        eventTap = makeEventTap()
        
        guard let eventTap else {
            return print("Failed to create event tap.")
        }
        
        enableEventTap(eventTap)
    }
    
    private func makeEventTap() -> CFMachPort? {
        CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: KeyboardMonitor.eventMask,
            callback: KeyboardMonitor.eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
    }
    
    private func enableEventTap(_ eventTap: CFMachPort) {
        runLoopSource = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        )
        
        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            runLoopSource,
            .commonModes
        )
        
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    @discardableResult
    func handle(event: CGEvent, ofType type: CGEventType) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }
        
        let nsEvent = NSEvent(cgEvent: event)
        
        if let nsEvent, currentShortcut.matches(event: nsEvent) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                self.delegate?.keyboardMonitor(self, didDetectShortcut: self.currentShortcut)
            }
            
            return nil
        }
        
        if let nsEvent, delegate?.keyboardMonitor(self, shouldBlockEvent: nsEvent) == true {
            return nil
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    private func stopMonitoring() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        
        runLoopSource = nil
        eventTap = nil
    }
}
