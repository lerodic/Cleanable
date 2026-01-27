import AppKit
import Foundation

class ShortcutRecorder {
    weak var delegate: ShortcutRecorderDelegate?

    private var isRecording = false
    private var localMonitor: Any?

    deinit {
        stopRecording()
    }

    func stopRecording() {
        guard isRecording else { return }

        isRecording = false

        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)

            localMonitor = nil
        }
    }

    func startRecording() {
        guard !isRecording else { return }

        isRecording = true

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleRecordingEvent(event)

            return nil
        }
    }

    func handleRecordingEvent(_ event: NSEvent) {
        guard isRecording else { return }
        guard hasModifiers(event) else { return }

        let modifierFlags = UInt(event.modifierFlags.rawValue) & UInt(
            NSEvent.ModifierFlags.control.rawValue |
                NSEvent.ModifierFlags.option.rawValue |
                NSEvent.ModifierFlags.shift.rawValue |
                NSEvent.ModifierFlags.command.rawValue
        )

        let shortcut = KeyboardShortcut(
            keyCode: event.keyCode,
            modifierFlags: modifierFlags
        )

        stopRecording()

        delegate?.shortcutRecorder(self, didRecordShortcut: shortcut)
    }

    private func hasModifiers(_ event: NSEvent) -> Bool {
        !event.modifierFlags.intersection([.command, .option, .control, .shift]).isEmpty
    }
}
