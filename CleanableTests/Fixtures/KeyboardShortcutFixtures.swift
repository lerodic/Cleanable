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

struct MatchesCase: @unchecked Sendable {
    let shortcut: KeyboardShortcut
    let event: NSEvent
}

let matchesWithMatchingEventsFixtures: [MatchesCase] = [
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.option.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.command, .option],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "l",
            charactersIgnoringModifiers: "l",
            isARepeat: false,
            keyCode: 37
        )!
    ),
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 2,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.control.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.command, .option, .control],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "d",
            charactersIgnoringModifiers: "d",
            isARepeat: false,
            keyCode: 2
        )!
    ),
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 32,
            modifierFlags: UInt(NSEvent.ModifierFlags.shift.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.shift],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "u",
            charactersIgnoringModifiers: "u",
            isARepeat: false,
            keyCode: 32
        )!
    )
]

let matchesWithNonMatchingEventsFixtures: [MatchesCase] = [
    // different keyCodes; "l" vs "k"
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.option.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.command, .option],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "k",
            charactersIgnoringModifiers: "k",
            isARepeat: false,
            keyCode: 40
        )!
    ),
    // missing 'control' modifier
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 2,
            modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.control.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.command, .option],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "d",
            charactersIgnoringModifiers: "d",
            isARepeat: false,
            keyCode: 2
        )!
    ),
    // contains additional modifier: 'option'
    .init(
        shortcut:
        KeyboardShortcut(
            keyCode: 32,
            modifierFlags: UInt(NSEvent.ModifierFlags.shift.rawValue)
        ),
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.shift, .option],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "u",
            charactersIgnoringModifiers: "u",
            isARepeat: false,
            keyCode: 32
        )!
    )
]
