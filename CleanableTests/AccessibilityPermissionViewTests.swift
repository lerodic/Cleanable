@testable import Cleanable
import SwiftUI
import Testing
import ViewInspector

@MainActor
@Suite("AccessibilityPermissionView Tests", .serialized)
struct AccessibilityPermissionViewTests {
    @Test("Displays correct title text")
    func displayCorrectTitle() throws {
        let view = AccessibilityPermissionView(
            onOpenSettings: {},
            onDismiss: {}
        )
        let text = "Accessibility Permission Required"
        
        let titleText = try view.inspect().find(text: text)
        
        #expect(try titleText.string() == text)
    }
    
    @Test("Displays correct description text")
    func displayCorrectDescription() throws {
        let view = AccessibilityPermissionView(
            onOpenSettings: {},
            onDismiss: {}
        )
        let text = "Cleanable needs Accessibility permission to monitor keyboard shortcuts and control keyboard input."
        
        let descriptionText = try view.inspect().find(text: text)
        
        #expect(try descriptionText.string() == text)
    }
    
    @Test("Has correct set of buttons")
    func correctSetOfButtons() throws {
        let view = AccessibilityPermissionView(
            onOpenSettings: {},
            onDismiss: {}
        )
        let openSettingsButtonText = "Open System Settings"
        let openLaterButtonText = "Later"
        
        let openSettingsButton = try view.inspect().find(button: openSettingsButtonText)
        let openLaterButton = try view.inspect().find(button: openLaterButtonText)
        
        #expect(try openSettingsButton.labelView().text().string() == openSettingsButtonText)
        #expect(try openLaterButton.labelView().text().string() == openLaterButtonText)
    }
    
    @Test("Tapping button triggers callback", arguments: ["Open System Settings", "Later"])
    func tappingButtonTriggersCallback(_ buttonText: String) throws {
        var callbackCalled = false
        let view = AccessibilityPermissionView(
            onOpenSettings: {},
            onDismiss: { callbackCalled = true }
        )
        
        let button = try view.inspect().find(button: buttonText)
        try button.tap()
        
        #expect(callbackCalled == true)
    }
    
    @Test("Instructions section contains correct entries")
    func instructionsSectionContainsCorrectEntries() throws {
        let view = AccessibilityPermissionView(
            onOpenSettings: {},
            onDismiss: {}
        )
        let entries = [
            "Click 'Open System Settings' below",
            "Enable Cleanable in the Accessibility list",
            "Return to Cleanable to start using it"
        ]
        
        for entry in entries {
            let sectionEntry = try view.inspect().find(text: entry)
            
            #expect(try sectionEntry.string() == entry)
        }
    }
}
