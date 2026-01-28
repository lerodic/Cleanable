import AppKit
@testable import Cleanable
import Foundation
import Testing

@Suite("LockViewModel Tests")
struct LockViewModelTests {
    @Test("Initializes in unlocked state")
    func initialState() {
        let viewModel = LockViewModel()

        #expect(viewModel.isLocked == false)
    }

    @Test("'toggleLock' toggles from unlocked -> locked")
    func toggleToUnlocked() {
        let viewModel = LockViewModel()
        
        #expect(viewModel.isLocked == false)
        
        viewModel.toggleLock()
        
        #expect(viewModel.isLocked == true)
    }

    @Test("'toggleLock' toggles from locked -> unlocked")
    func toggleToLocked() {
        let viewModel = LockViewModel()
        viewModel.toggleLock()
        
        #expect(viewModel.isLocked == true)
        
        viewModel.toggleLock()
        
        #expect(viewModel.isLocked == false)
    }
    
    @MainActor
    @Test("State change callback is invoked")
    func stateChangeCallbackIsInvoked() async {
        let viewModel = LockViewModel()
        var hasCallbackBeenInvoked = false
        var callbackValue = false
        
        viewModel.onStateChange = { isLocked in
            hasCallbackBeenInvoked = true
            callbackValue = isLocked
        }
        
        viewModel.toggleLock()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(hasCallbackBeenInvoked == true)
        #expect(callbackValue == true)
    }
    
    @Test("Correct state is maintained across multiple toggles")
    func correctStateAcrossMultipleToggles() {
        let viewModel = LockViewModel()
        
        for i in 1 ... 10 {
            viewModel.toggleLock()
            
            #expect(viewModel.isLocked == (i % 2 == 1))
        }
    }
    
    @Test("Shortcut defaults to Control+Option+Command+L")
    func defaultShortcut() {
        let viewModel = LockViewModel()
        
        #expect(viewModel.shortcutDescription == "⌃⌥⌘L")
    }
    
    @Test("Shortcut resets to default when requested")
    func restoreDefaultShortcut() {
        let viewModel = LockViewModel()
        viewModel.updateShortcut(KeyboardShortcut(keyCode: 2, modifierFlags: NSEvent.ModifierFlags.option.rawValue))
        
        #expect(viewModel.shortcutDescription == "⌥D")
        
        viewModel.restoreDefaultShortcut()
        
        #expect(viewModel.shortcutDescription == "⌃⌥⌘L")
    }
    
    @MainActor
    @Test("Shortcut change callback is invoked")
    func invokeChangeCallback() async {
        let viewModel = LockViewModel()
        var hasCallbackBeenInvoked = false
        
        viewModel.onShortcutChange = {
            hasCallbackBeenInvoked = true
        }
        
        viewModel.restoreDefaultShortcut()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(hasCallbackBeenInvoked == true)
    }
}
