import AppKit
@testable import Cleanable
import Foundation
import Testing

@MainActor
@Suite("PermissionsService Tests", .serialized)
struct PermissionsServiceTests {
    final class MockWindowPresenter: WindowPresenter, @unchecked Sendable {
        var permissionWindowCreated = false
        var permissionWindowShown = false
        var permissionWindowClosed = false

        var restartWindowCreated = false
        var restartWindowShown = false
        var restartWindowClosed = false

        override func showPermissionWindow(onOpenSettings: @escaping () -> Void, onDismiss: @escaping () -> Void) {
            permissionWindowCreated = true
            permissionWindowShown = true
        }

        override func closePermissionWindow() {
            permissionWindowClosed = true
        }

        override func showRestartWindow(onRestart: @escaping () -> Void, onQuit: @escaping () -> Void) {
            restartWindowCreated = true
            restartWindowShown = true
        }

        override func closeRestartWindow() {
            restartWindowClosed = true
        }
    }

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

    @Test("Shows permission window when permission has not been granted")
    func createsAlertCorrectly() {
        let service = PermissionsService()
        var windowShown = false

        service.hasAccessibilityPermissions = { false }

        service.showAccessibilityAlert()
        windowShown = true

        #expect(windowShown == true)
    }

    @Test("Opens settings panel with correct URL")
    func openSettingsPanelWithCorrectURL() {
        let service = PermissionsService()
        var openedUrl: URL?

        service.openWorkspace = { url in
            openedUrl = url
        }

        service.openSettingsPanel(at: PermissionsService.accessibilitySettingsUrl)

        #expect(openedUrl?.absoluteString == PermissionsService.accessibilitySettingsUrl)
    }

    @Test("Handles invalid URL gracefully")
    func handleInvalidURLGracefully() {
        let service = PermissionsService()
        var workspaceCalled = false

        service.openWorkspace = { _ in
            workspaceCalled = true
        }

        service.openSettingsPanel(at: "Invalid URL")

        #expect(workspaceCalled == false)
    }

    @Test("Shows permission window when alert is triggered")
    func showsPermissionWindowWhenAlertIsTriggered() {
        let mockPresenter = MockWindowPresenter()
        let service = PermissionsService(presenter: mockPresenter)

        service.showAccessibilityAlert()

        #expect(mockPresenter.permissionWindowCreated == true)
        #expect(mockPresenter.permissionWindowShown == true)
    }

    @Test("Shows alert when permissions have not been granted")
    func requestPermissionsAfterDelay() async {
        let mockPresenter = MockWindowPresenter()
        let service = PermissionsService(presenter: mockPresenter)

        service.hasAccessibilityPermissions = { false }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(mockPresenter.permissionWindowShown == true)
    }

    @Test("Does not show alert when permissions have already been granted")
    func noAlertWhenPermissionsHaveBeenGranted() async {
        let mockPresenter = MockWindowPresenter()
        let service = PermissionsService(presenter: mockPresenter)

        service.hasAccessibilityPermissions = { true }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(mockPresenter.permissionWindowShown == false)
    }

    @Test("Restart intent triggers app restart")
    func triggerAppRestart() {
        let service = PermissionsService()
        var didRestart = false

        service.restartApp = {
            didRestart = true
        }

        service.userRequestedRestart()

        #expect(didRestart == true)
    }

    @Test("Quit intent triggers app quit")
    func triggerAppQuit() {
        let service = PermissionsService()
        var didQuit = false

        service.quitApp = {
            didQuit = true
        }

        service.userRequestedQuit()

        #expect(didQuit == true)
    }
}
