import AppKit
@testable import Cleanable
import Foundation

struct ShortcutDescriptionCase {
    let shortcut: KeyboardShortcut
    let description: String
}

let shortcutDescriptionFixtures: [ShortcutDescriptionCase] = [
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 37,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.option.rawValue)
        ),
        description: "⌥⌘L"
    ),
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 15,
            modifierFlags: UInt(NSEvent.ModifierFlags.shift.rawValue)
        ),
        description: "⇧R"
    ),
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 32,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue)
        ),
        description: "⌘U"
    ),
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 7,
            modifierFlags: UInt(NSEvent.ModifierFlags.shift.rawValue | NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.command.rawValue)
        ),
        description: "⇧⌃⌥⌘X"
    )
]

struct ShortcutEqualityCase {
    let shortcut1: KeyboardShortcut
    let shortcut2: KeyboardShortcut
}

let shortcutEqualityFixtures: [ShortcutEqualityCase] = [
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 7, modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 7, modifierFlags: NSEvent.ModifierFlags.option.rawValue
        )
    ),
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 12, modifierFlags: NSEvent.ModifierFlags.shift.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 12, modifierFlags: NSEvent.ModifierFlags.shift.rawValue
        )
    ),
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 19, modifierFlags: NSEvent.ModifierFlags.capsLock.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 19, modifierFlags: NSEvent.ModifierFlags.capsLock.rawValue
        )
    )
]

let shortcutInequalityFixtures: [ShortcutEqualityCase] = [
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 7, modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 8, modifierFlags: NSEvent.ModifierFlags.option.rawValue
        )
    ),
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 12, modifierFlags: NSEvent.ModifierFlags.shift.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 19, modifierFlags: NSEvent.ModifierFlags.shift.rawValue
        )
    ),
    .init(
        shortcut1: KeyboardShortcut(
            keyCode: 19, modifierFlags: NSEvent.ModifierFlags.shift.rawValue
        ),
        shortcut2: KeyboardShortcut(
            keyCode: 19, modifierFlags: NSEvent.ModifierFlags.capsLock.rawValue
        )
    )
]
