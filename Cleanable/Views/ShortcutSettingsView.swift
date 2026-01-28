import SwiftUI

struct ShortcutSettingsView: View {
    @ObservedObject var viewModel: LockViewModel
    @State private var isRecording = false

    func restoreDefaultShortcut() {
        viewModel.restoreDefaultShortcut()
        isRecording = false
    }

    var body: some View {
        VStack(spacing: 20) {
            headerSection
            shortcutDisplaySection
            tipsSection
            Spacer()
            resetButton
        }
        .padding(24)
        .frame(width: 400)
        .onReceive(viewModel.$recordedShortcut) { _ in
            if isRecording {
                isRecording = false
            }
        }
    }

    private var headerSection: some View {
        Text("Keyboard shortcut")
            .font(.headline)
    }

    private var shortcutDisplaySection: some View {
        VStack(spacing: 12) {
            Text("Current shortcut:")
                .foregroundStyle(.secondary)

            HStack {
                Text(viewModel.shortcutDescription)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .frame(minWidth: 150)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)

                Button(isRecording ? "Press keys..." : "Record new") {
                    isRecording.toggle()

                    if isRecording {
                        viewModel.startRecordingShortcut()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if isRecording {
                Text("Press your prefered combination of keys")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tips:")
                .font(.subheadline)
                .fontWeight(.semibold)

            Group {
                Text("• Use modifier keys (⌘, ⌥, ⌃, ⇧) with a letter or number")
                Text("• Avoid common system shortcuts")
                Text("• The shortcut works even when your keyboard is locked")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var resetButton: some View {
        Button("Restore default (⌃⌥⌘L)") {
            restoreDefaultShortcut()
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    ShortcutSettingsView(viewModel: LockViewModel())
}
