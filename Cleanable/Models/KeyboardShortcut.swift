import AppKit
import Foundation

struct KeyboardShortcut: Codable, Equatable {
    let keyCode: UInt16
    let modifierFlags: UInt
    
    // Defaults to "Control" + "Option" + "Command" + "L"
    static var defaultShortcut: KeyboardShortcut {
        KeyboardShortcut(
            keyCode: 37,
            modifierFlags: UInt(
                NSEvent.ModifierFlags.control.rawValue |
                    NSEvent.ModifierFlags.option.rawValue |
                    NSEvent.ModifierFlags.command.rawValue
            )
        )
    }
    
    var description: String {
        var parts: [String] = getModifierKeys()
        
        if let key = keyCodeAsString(keyCode) {
            parts.append(key)
        }
        
        return parts.joined()
    }
    
    private func getModifierKeys() -> [String] {
        var modifierKeys: [String] = []
        
        if includesShiftKey() {
            modifierKeys.append("⇧")
        }
        
        if includesControlKey() {
            modifierKeys.append("⌃")
        }
        
        if includesOptionKey() {
            modifierKeys.append("⌥")
        }
        
        if includesCommandKey() {
            modifierKeys.append("⌘")
        }
        
        return modifierKeys
    }
    
    private func includesControlKey() -> Bool {
        modifierFlags & UInt(NSEvent.ModifierFlags.control.rawValue) != 0
    }
    
    private func includesOptionKey() -> Bool {
        modifierFlags & UInt(NSEvent.ModifierFlags.option.rawValue) != 0
    }
    
    private func includesShiftKey() -> Bool {
        modifierFlags & UInt(NSEvent.ModifierFlags.shift.rawValue) != 0
    }
    
    private func includesCommandKey() -> Bool {
        modifierFlags & UInt(NSEvent.ModifierFlags.command.rawValue) != 0
    }
    
    private func keyCodeAsString(_ keyCode: UInt16) -> String? {
        let keyMap: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
            11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1", 19: "2",
            20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8",
            29: "0", 30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L", 38: "J",
            39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
            49: "Space", 50: "`"
        ]
        
        return keyMap[keyCode]
    }
    
    func matches(event: NSEvent) -> Bool {
        let modifiers = UInt(event.modifierFlags.rawValue) & UInt(
            NSEvent.ModifierFlags.command.rawValue |
                NSEvent.ModifierFlags.option.rawValue |
                NSEvent.ModifierFlags.control.rawValue |
                NSEvent.ModifierFlags.shift.rawValue
        )
        
        return event.keyCode == keyCode && modifiers == modifierFlags
    }
}
