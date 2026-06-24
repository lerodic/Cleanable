import AppKit
import Foundation

class KeyboardMonitor {
    private enum MediaKeyType: Int {
        case volumeUp = 0
        case volumeDown = 1
        case mute = 7
        case play = 16
        case next = 17
        case previous = 18
        case fastForward = 19
        case rewind = 20
    }
    
    weak var delegate: KeyboardMonitorDelegate?
    
    private static var eventMask: CGEventMask {
        return (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << 14)
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
        if shouldBlockKeyPress(type, event) {
            return nil
        }

        guard shouldBlockEvent(event) else {
            return Unmanaged.passUnretained(event)
        }

        if isAudioKey(type) {
            return handleAudioKey(event)
        }

        return nil
    }
    
    private func shouldBlockKeyPress(_ type: CGEventType, _ event: CGEvent) -> Bool {
        return type == .keyDown && handleKeyPress(event)
    }
    
    private func handleKeyPress(_ event: CGEvent) -> Bool {
        let nsEvent = NSEvent(cgEvent: event)

        if let nsEvent, currentShortcut.matches(event: nsEvent) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.keyboardMonitor(self, didDetectShortcut: self.currentShortcut)
            }
            
            return true
        }
        
        return false
    }
    
    private func shouldBlockEvent(_ event: CGEvent) -> Bool {
        guard let nsEvent = NSEvent(cgEvent: event) else { return false }
            
        return delegate?.keyboardMonitor(self, shouldBlockEvent: nsEvent) == true
    }
    
    private func isAudioKey(_ type: CGEventType) -> Bool {
        return type.rawValue == 14
    }
    
    private func handleAudioKey(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        guard let nsEvent = NSEvent(cgEvent: event), nsEvent.subtype.rawValue == 8 else {
            return Unmanaged.passUnretained(event)
        }

        let keyType = (nsEvent.data1 & 0xFFFF0000) >> 16
        
        return MediaKeyType(rawValue: keyType) != nil
            ? nil
            : Unmanaged.passUnretained(event)
    }
    
    func setFnKeysAsStandard(_ enabled: Bool) {
        writeFnKeyState(enabled)
        readFnKeyState()
    }
    
    private func writeFnKeyState(_ enabled: Bool) {
        let value = enabled ? "1" : "0"
        let process = createFnStateProcess("write", "com.apple.keyboard.fnState", value)
        
        try? process.run()
        process.waitUntilExit()
    }
    
    private func readFnKeyState() {
        let notifyProcess = createFnStateProcess("read", "com.apple.keyboard.fnState")
            
        try? notifyProcess.run()
    }
    
    private func createFnStateProcess(_ arguments: String...) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = arguments
        
        return process
    }
    
    private func stopMonitoring() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        
        runLoopSource = nil
        eventTap = nil
    }
}
