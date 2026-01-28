import SwiftUI

struct AccessibilityPermissionView: View {
    let onOpenSettings: () -> Void
    let onDismiss: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            AppIconSection(isAnimating: $isAnimating)
            messageSection
            InstructionsSection()
            buttonSection
        }
        .padding(32)
        .frame(width: 480)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }

    struct AppIconSection: View {
        @Binding var isAnimating: Bool
        @Environment(\.colorScheme) private var colorScheme

        var shapeFillOpacity: Double {
            colorScheme == .dark ? 0.5 : 0.1
        }

        var shapeOpacity: Double {
            if colorScheme == .dark {
                return isAnimating ? 0.1 : 0.5
            } else {
                return isAnimating ? 0.3 : 0.6
            }
        }

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.accentColor.opacity(shapeFillOpacity))
                    .frame(width: 72, height: 72)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(shapeOpacity)

                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var messageSection: some View {
        VStack(spacing: 8) {
            Text("Accessibility Permission Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Cleanable needs Accessibility permission to monitor keyboard shortcuts and control keyboard input.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    struct InstructionsSection: View {
        let entries: [String] = [
            "Click 'Open System Settings' below",
            "Enable Cleanable in the Accessibility list",
            "Return to Cleanable to start using it",
        ]

        struct InstructionEntry: View {
            let index: Int
            let content: String

            var body: some View {
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.accentColor)
                        .clipShape(Circle())

                    Text(content)
                        .font(.body)
                }
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                    InstructionEntry(index: index, content: entry)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var buttonSection: some View {
        HStack(spacing: 12) {
            Button("Later") {
                onDismiss()
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.cancelAction)

            Button("Open System Settings") {
                onOpenSettings()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    AccessibilityPermissionView(
        onOpenSettings: { print("Open settings") },
        onDismiss: { print("Dismiss") }
    )
}
