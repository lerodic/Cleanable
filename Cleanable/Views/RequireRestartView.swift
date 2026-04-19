import SwiftUI

struct RequireRestartView: View {
    let onRestart: () -> Void
    let onQuit: () -> Void

    @State private var isAnimating = false

    var body: some View {
        RequireRestartContent(
            isAnimating: $isAnimating,
            onRestart: onRestart,
            onQuit: onQuit
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

struct RequireRestartContent: View {
    @Binding var isAnimating: Bool
    let onRestart: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            iconSection
            messageSection
            buttonSection
        }
        .padding(32)
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.3 : 0.6)

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.green)
                .symbolEffect(.bounce, options: .speed(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var messageSection: some View {
        VStack(spacing: 12) {
            Text("Permission Granted")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Cleanable needs to restart to activate keyboard monitoring.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var buttonSection: some View {
        HStack(spacing: 12) {
            Button("Quit") {
                onQuit()
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.cancelAction)

            Button("Restart Now") {
                onRestart()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    RequireRestartView(
        onRestart: {},
        onQuit: {}
    )
}
