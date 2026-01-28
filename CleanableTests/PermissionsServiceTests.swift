import AppKit
@testable import Cleanable
import Foundation
import Testing

@MainActor
@Suite("PermissionsService Tests", .serialized)
struct PermissionsServiceTests {
    @Test("Accessibility settings URL is formatted correctly")
    func settingsURLHasCorrectFormat() {
        let url = PermissionsService.accessibilitySettingsUrl

        #expect(url.hasPrefix("x-apple.systempreferences:"))
        #expect(url.contains("Privacy_Accessibility"))
    }

    @Test("Receives correct state of accessibility permissions via AX", arguments: [true, false])
    func receivesCorrectStateOfPermissions(axIsProcessTrusted: Bool) {
        let service = PermissionsService()
        service.hasAccessibilityPermissions = { axIsProcessTrusted }

        #expect(service.hasAccessibilityPermissions() == axIsProcessTrusted)
    }

    @Test("Creates alert with correct properties")
    func createsAlertCorrectly() {
        let service = PermissionsService()
        let alert = service.makeAccessibilityAlert()

        #expect(alert.messageText == "Accessibility permission required")
        #expect(alert.informativeText.contains("Cleanable needs Accessibility permission"))
        #expect(alert.alertStyle == .warning)
        #expect(alert.buttons.count == 2)
        #expect(alert.buttons[0].title == "Open System Settings")
        #expect(alert.buttons[1].title == "Later")
    }

    @Test("Opens settings when 'Open System Settings' button is clicked")
    func openSettingsWhenButtonIsClicked() {
        let service = PermissionsService()
        var settingsOpened = false
        var openedUrl: URL?

        service.showAlert = { _ in .alertFirstButtonReturn }
        service.openWorkspace = { url in
            settingsOpened = true
            openedUrl = url
        }

        service.showAccessibilityAlert()

        #expect(settingsOpened == true)
        #expect(openedUrl?.absoluteString == PermissionsService.accessibilitySettingsUrl)
    }

    @Test("Settings is not opened when user clicks 'Later' button")
    func dontOpenSettingsWhenButtonIsClicked() {
        let service = PermissionsService()
        var settingsOpened = false

        service.showAlert = { _ in .alertSecondButtonReturn }
        service.openWorkspace = { _ in
            settingsOpened = true
        }

        service.showAccessibilityAlert()

        #expect(settingsOpened == false)
    }

    @MainActor
    @Test("Shows alert when permissions have not been granted")
    func showAlertWhenPermissionsHaveNotBeenGranted() async {
        let service = PermissionsService()
        var alertShown = false

        service.hasAccessibilityPermissions = { false }
        service.showAlert = { _ in
            alertShown = true

            return .alertSecondButtonReturn
        }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(alertShown == true)
    }

    @MainActor
    @Test("Does not show alert when permissions have already been granted")
    func noAlertWhenPermissionsHaveBeenGranted() async {
        let service = PermissionsService()
        var alertShown = false

        service.hasAccessibilityPermissions = { true }
        service.showAlert = { _ in
            alertShown = true

            return .alertSecondButtonReturn
        }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(alertShown == false)
    }
}
