import AppKit

protocol KeyboardMonitorDelegate: AnyObject {
    func keyboardMonitor(_ monitor: KeyboardMonitor, didDetectShortcut shortcut: KeyboardShortcut)
    func keyboardMonitor(_ monitor: KeyboardMonitor, shouldBlockEvent event: NSEvent) -> Bool
}
