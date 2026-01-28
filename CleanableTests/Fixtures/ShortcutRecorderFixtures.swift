import AppKit
@testable import Cleanable
import Foundation

let defaultEvent = NSEvent.keyEvent(
    with: .keyDown,
    location: NSPoint.zero,
    modifierFlags: [.command],
    timestamp: 0,
    windowNumber: 0,
    context: nil,
    characters: "l",
    charactersIgnoringModifiers: "l",
    isARepeat: false,
    keyCode: 37
)!

struct ExistingModifierCase: @unchecked Sendable {
    let event: NSEvent
    let shortcut: KeyboardShortcut
    let description: String
}

let existingModifierFixtures: [ExistingModifierCase] = [
    .init(
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.shift],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "l",
            charactersIgnoringModifiers: "l",
            isARepeat: false,
            keyCode: 37
        )!,
        shortcut: KeyboardShortcut(keyCode: 37, modifierFlags: NSEvent.ModifierFlags.shift.rawValue),
        description: "⇧L"
    ),
    .init(
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [.shift, .option],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "e",
            charactersIgnoringModifiers: "e",
            isARepeat: false,
            keyCode: 14
        )!,
        shortcut: KeyboardShortcut(keyCode: 14, modifierFlags: NSEvent.ModifierFlags.shift.rawValue | NSEvent.ModifierFlags.option.rawValue),
        description: "⇧⌥E"
    )
]

struct MissingModifierCase: @unchecked Sendable {
    let event: NSEvent
}

let missingModifierFixtures: [MissingModifierCase] = [
    .init(
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [],
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
        event:
        NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "e",
            charactersIgnoringModifiers: "e",
            isARepeat: false,
            keyCode: 14
        )!
    )
]
