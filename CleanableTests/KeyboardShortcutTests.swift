import AppKit
@testable import Cleanable
import Foundation
import Testing

@Suite("KeyboardShortcut Tests")
struct KeyboardShortcutTests {
    @Test("Shortcut description has correct format", arguments: shortcutDescriptionFixtures)
    func shortcutDescription(_ testCase: ShortcutDescriptionCase) {
        let shortcut = testCase.shortcut

        #expect(shortcut.description == testCase.description)
    }

    @Test("Shortcuts with same values are equal", arguments: shortcutEqualityFixtures)
    func shortcutEquality(_ testCase: ShortcutEqualityCase) {
        #expect(testCase.shortcut1 == testCase.shortcut2)
    }

    @Test("Shortcuts with different values are not equal", arguments: shortcutInequalityFixtures)
    func shortcutInequality(_ testCase: ShortcutEqualityCase) {
        #expect(testCase.shortcut1 != testCase.shortcut2)
    }

    @Test("Shortcut defaults to Control+Option+Command+L")
    func defaultShortcut() {
        let shortcut = KeyboardShortcut.defaultShortcut

        #expect(shortcut.description == "⌃⌥⌘L")
        #expect(shortcut.keyCode == 37)
    }
}
