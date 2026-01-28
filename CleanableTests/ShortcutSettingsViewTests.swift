@testable import Cleanable
import SwiftUI
import Testing
import ViewInspector

@MainActor
@Suite("ShortcutSettingsView Tests", .serialized)
struct ShortcutSettingsViewTests {
    @Test("View displays current shortcut description")
    func displayCurrentShortcutDescription() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)

        let text = try view.inspect().find(text: viewModel.shortcutDescription)

        #expect(try text.string() == viewModel.shortcutDescription)
    }

    @Test("View has header text")
    func hasHeaderText() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)
        let headerText = "Keyboard shortcut"

        let header = try view.inspect().find(text: headerText)

        #expect(try header.string() == headerText)
    }

    @Test("View has record button")
    func hasRecordButton() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)
        let buttonText = "Record new"

        let button = try view.inspect().find(button: buttonText)

        #expect(try button.labelView().text().string() == buttonText)
    }

    @Test("View has reset button")
    func hasResetButton() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)
        let buttonText = "Restore default (⌃⌥⌘L)"

        let button = try view.inspect().find(button: buttonText)

        #expect(try button.labelView().text().string() == buttonText)
    }

    @Test("View displays tips section")
    func displaysTipsSection() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)
        let sectionText = "Tips:"

        let section = try view.inspect().find(text: sectionText)

        #expect(try section.string() == sectionText)
    }

    @Test("Reset button triggers view model reset")
    func triggerViewModelReset() throws {
        let viewModel = LockViewModel()
        let view = ShortcutSettingsView(viewModel: viewModel)

        viewModel.updateShortcut(
            KeyboardShortcut(
                keyCode: 2,
                modifierFlags: NSEvent.ModifierFlags.option.rawValue
            )
        )
        let initialDescription = viewModel.shortcutDescription

        let button = try view.inspect().find(button: "Restore default (⌃⌥⌘L)")
        try button.tap()

        #expect(initialDescription == "⌥D")
        #expect(viewModel.shortcutDescription == "⌃⌥⌘L")
    }
}
