import AppKit
@testable import Cleanable
import Testing

@MainActor
@Suite("ShortcutWindowController Tests")
struct ShortcutWindowControllerTests {
    @Test("Show presents a window with the correct title")
    func showPresentsWindowWithCorrectTitle() {
        let controller = ShortcutWindowController(viewModel: LockViewModel())

        controller.show()

        let window = NSApp.windows.first { $0.title == "Configure shortcut" }

        #expect(window != nil)
    }

    @Test("Show reuses the same window on subsequent calls")
    func showReusesSameWindow() {
        let controller = ShortcutWindowController(viewModel: LockViewModel())

        controller.show()
        let firstWindow = NSApp.windows.first { $0.title == "Configure shortcut" }

        controller.show()
        let secondWindow = NSApp.windows.first { $0.title == "Configure shortcut" }

        #expect(firstWindow === secondWindow)
    }

    @Test("Show makes the window visible")
    func showMakesWindowVisible() {
        let controller = ShortcutWindowController(viewModel: LockViewModel())

        controller.show()

        let window = NSApp.windows.first { $0.title == "Configure shortcut" }

        #expect(window?.isVisible == true)
    }
}
