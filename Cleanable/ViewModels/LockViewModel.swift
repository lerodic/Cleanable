import AppKit
import Combine
import Foundation

class LockViewModel: ObservableObject, @unchecked Sendable {
    @Published private(set) var isLocked: Bool = false
    @Published var recordedShortcut: KeyboardShortcut?
    @Published private(set) var currentShortcut: KeyboardShortcut
    
    private static let userDefaultsKey = "keyboardShortcut"
    
    var onStateChange: ((Bool) -> Void)?
    var onShortcutChange: (() -> Void)?
    
    private var keyboardMonitor: KeyboardMonitor?
    private let shortcutRecorder: ShortcutRecorder
    
    var shortcutDescription: String {
        currentShortcut.description
    }
    
    init() {
        let shortcut = Self.initShortcut()
        
        currentShortcut = shortcut
        shortcutRecorder = ShortcutRecorder()
        
        if AXIsProcessTrusted() {
            keyboardMonitor = KeyboardMonitor(shortcut: shortcut)
            keyboardMonitor?.delegate = self
        }
        
        shortcutRecorder.delegate = self
    }
    
    deinit {
        keyboardMonitor = nil
    }
    
    private static func initShortcut() -> KeyboardShortcut {
        loadShortcut() ?? .defaultShortcut
    }
    
    private static func loadShortcut() -> KeyboardShortcut? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey), let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) else {
            return nil
        }
        
        return shortcut
    }
    
    func toggleLock() {
        isLocked.toggle()
        
        onStateChange?(isLocked)
    }
    
    func startRecordingShortcut() {
        shortcutRecorder.startRecording()
    }
    
    func restoreDefaultShortcut() {
        updateShortcut(.defaultShortcut)
    }
    
    func updateShortcut(_ shortcut: KeyboardShortcut) {
        currentShortcut = shortcut
        keyboardMonitor?.updateShortcut(shortcut)
        saveShortcut(shortcut)
        onShortcutChange?()
    }
    
    private func saveShortcut(_ shortcut: KeyboardShortcut) {
        if let encoded = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }
}

extension LockViewModel: KeyboardMonitorDelegate {
    func keyboardMonitor(_ monitor: KeyboardMonitor, didDetectShortcut shortcut: KeyboardShortcut) {
        toggleLock()
    }
    
    func keyboardMonitor(_ monitor: KeyboardMonitor, shouldBlockEvent event: NSEvent) -> Bool {
        return isLocked
    }
}

extension LockViewModel: ShortcutRecorderDelegate {
    func shortcutRecorder(_ recorder: ShortcutRecorder, didRecordShortcut shortcut: KeyboardShortcut) {
        recordedShortcut = shortcut
        
        updateShortcut(shortcut)
    }
}
