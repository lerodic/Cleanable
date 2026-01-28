import AppKit
@testable import Cleanable
import Foundation

struct UpdateShortcutCase {
    let initialShortcut: KeyboardShortcut
    let newShortcut: KeyboardShortcut
}

let updateShortcutFixtures: [UpdateShortcutCase] = [
    // updated keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        )
    ),
    // additional modifier, same keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        )
    ),
    // additional modifier, new keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        )
    ),
    // reduced number of modifiers, same keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        )
    ),
    // reduced number of modifiers, new keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        )
    )
]

struct DetectsMatchingShortcutCase {
    let shortcut: KeyboardShortcut
    let event: CGEvent
}

func makeCGEvent(keyCode: CGKeyCode, flags: CGEventFlags, keyDown: Bool = true) -> CGEvent {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: keyDown)!
    event.flags = flags

    return event
}

let detectsMatchingShortcutFixtures: [DetectsMatchingShortcutCase] = [
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        event: makeCGEvent(keyCode: 37, flags: [.maskAlternate])
    ),
    .init(
        shortcut: KeyboardShortcut(
            keyCode: 12,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        event: makeCGEvent(keyCode: 12, flags: [.maskAlternate, .maskCommand, .maskShift])
    )
]

struct UpdateShortcutAndRecognizeCase {
    let initialShortcut: KeyboardShortcut
    let newShortcut: KeyboardShortcut
    let event: CGEvent
}

let updateShortcutAndRecognizeFixtures: [UpdateShortcutAndRecognizeCase] = [
    // updated keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        event: makeCGEvent(keyCode: 21, flags: [.maskAlternate])
    ),
    // additional modifier, same keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        event: makeCGEvent(keyCode: 37, flags: [.maskAlternate, .maskShift])
    ),
    // additional modifier, new keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        event: makeCGEvent(keyCode: 21, flags: [.maskAlternate, .maskShift])
    ),
    // reduced number of modifiers, same keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        event: makeCGEvent(keyCode: 37, flags: [.maskAlternate])
    ),
    // reduced number of modifiers, new keyCode
    .init(
        initialShortcut:
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.shift.rawValue
        ),
        newShortcut:
        KeyboardShortcut(
            keyCode: 21,
            modifierFlags: NSEvent.ModifierFlags.option.rawValue
        ),
        event: makeCGEvent(keyCode: 21, flags: [.maskAlternate])
    )
]
