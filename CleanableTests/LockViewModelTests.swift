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
    
    @Test("Returns nil for status item frame when provider is not set")
    func statusItemFrameWithNoProvider() {
        let viewModel = LockViewModel()
        let monitor = TrackpadMonitor()

        let frame = viewModel.trackpadMonitorStatusItemFrame(monitor)

        #expect(frame == nil)
    }

    @Test("Returns status item frame from provider")
    func statusItemFrameFromProvider() {
        let viewModel = LockViewModel()
        let monitor = TrackpadMonitor()
        let expectedFrame = CGRect(x: 0, y: 0, width: 100, height: 30)

        viewModel.statusItemFrameProvider = { expectedFrame }

        let frame = viewModel.trackpadMonitorStatusItemFrame(monitor)

        #expect(frame == expectedFrame)
    }

    @Test("Returns false for status item interaction when provider is not set")
    func statusItemInteractionWithNoProvider() {
        let viewModel = LockViewModel()
        let monitor = TrackpadMonitor()

        let isInteractive = viewModel.trackpadMonitorIsStatusItemInteractive(monitor)

        #expect(isInteractive == false)
    }

    @Test("Returns status item interaction state from provider")
    func statusItemInteractionFromProvider() {
        let viewModel = LockViewModel()
        let monitor = TrackpadMonitor()

        viewModel.statusItemInteractionProvider = { true }

        let isInteractive = viewModel.trackpadMonitorIsStatusItemInteractive(monitor)

        #expect(isInteractive == true)
    }
}
