import AppKit

protocol ShortcutRecorderDelegate: AnyObject {
    func shortcutRecorder(_ recorder: ShortcutRecorder, didRecordShortcut shortcut: KeyboardShortcut)
}
