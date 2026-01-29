@testable import Cleanable
import SwiftUI
import Testing
import ViewInspector

@MainActor
@Suite("RequireRestartView Tests", .serialized)
struct RequireRestartViewTests {
    @Test("Displays icon section correctly")
    func displaysIconSection() throws {
        let view = RequireRestartContent(
            isAnimating: .constant(false),
            onRestart: {},
            onQuit: {}
        )

        let icon = try view.inspect().find(ViewType.Image.self)

        #expect(try icon.actualImage().name() == Image(systemName: "checkmark.circle.fill").name())
    }
    
    @Test("Displays correct title text")
    func displayCorrectTitle() throws {
        let view = RequireRestartContent(
            isAnimating: .constant(false),
            onRestart: {},
            onQuit: {}
        )
        let text = "Permission Granted"
        
        let titleText = try view.inspect().find(text: text)
        
        #expect(try titleText.string() == text)
    }
    
    @Test("Displays correct description text")
    func displayCorrectDescription() throws {
        let view = RequireRestartContent(
            isAnimating: .constant(false),
            onRestart: {},
            onQuit: {}
        )
        let text = "Cleanable needs to restart to active keyboard monitoring."
        
        let descriptionText = try view.inspect().find(text: text)
        
        #expect(try descriptionText.string() == text)
    }
    
    @Test("Has correct set of buttons")
    func correctSetOfButtons() throws {
        let view = RequireRestartContent(
            isAnimating: .constant(false),
            onRestart: {},
            onQuit: {}
        )
        let restartButtonText = "Restart Now"
        let quitButtonText = "Quit"
        
        let restartButton = try view.inspect().find(button: restartButtonText)
        let quitButton = try view.inspect().find(button: quitButtonText)
        
        #expect(try restartButton.labelView().text().string() == restartButtonText)
        #expect(try quitButton.labelView().text().string() == quitButtonText)
    }
    
    @Test("Tapping button triggers callback", arguments: ["Restart Now", "Quit"])
    func tappingButtonTriggersCallback(_ buttonText: String) throws {
        var callbackCalled = false
        let view = RequireRestartContent(
            isAnimating: .constant(false),
            onRestart: { if buttonText == "Restart Now" { callbackCalled = true } },
            onQuit: { if buttonText == "Quit" { callbackCalled = true } }
        )
        
        let button = try view.inspect().find(button: buttonText)
        try button.tap()
        
        #expect(callbackCalled == true)
    }
}
