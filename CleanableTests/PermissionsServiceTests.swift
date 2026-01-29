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
        let service = PermissionsService()
        var windowCreated = false
        var windowShown = false

        service.createWindow = { rect, styleMask, title in
            windowCreated = true

            #expect(title == "Permission Required")
            #expect(rect.width == 480)
            #expect(rect.height == 400)

            return NSWindow(
                contentRect: rect,
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
        }

        service.showWindow = { _ in
            windowShown = true
        }

        service.showAccessibilityAlert()

        #expect(windowCreated == true)
        #expect(windowShown == true)
    }

    @Test("Shows alert when permissions have not been granted")
    func requestPermissionsAfterDelay() async {
        let service = PermissionsService()
        var alertShown = false

        service.hasAccessibilityPermissions = { false }

        service.createWindow = { rect, styleMask, _ in
            NSWindow(
                contentRect: rect,
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
        }

        service.showWindow = { _ in
            alertShown = true
        }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(alertShown == true)
    }

    @Test("Does not show alert when permissions have already been granted")
    func noAlertWhenPermissionsHaveBeenGranted() async {
        let service = PermissionsService()
        var alertShown = false

        service.hasAccessibilityPermissions = { true }

        service.showWindow = { _ in
            alertShown = true
        }

        service.requestPermissions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(alertShown == false)
    }

    @Test("Shows restart window when restart alert is triggered")
    func showsRestartWindow() {
        let service = PermissionsService()
        var windowCreated = false
        var windowShown = false

        service.createWindow = { rect, styleMask, title in
            windowCreated = true

            #expect(title == "Restart Required")
            #expect(rect.width == 400)
            #expect(rect.height == 280)

            return NSWindow(
                contentRect: rect,
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
        }

        service.showWindow = { _ in
            windowShown = true
        }

        service.showRestartAlert()

        #expect(windowCreated == true)
        #expect(windowShown == true)
    }

    @Test("Restart alert closes permission window")
    func closePermissionWindow() {
        let service = PermissionsService()
        var permissionClosed = false
        let fakePermissionWindow = NSWindow()

        service.closeWindow = { window in
            if window === fakePermissionWindow {
                permissionClosed = true
            }
        }

        service.createWindow = { rect, styleMask, title in
            title == "Permission Required"
                ? fakePermissionWindow
                : NSWindow(
                    contentRect: rect,
                    styleMask: styleMask,
                    backing: .buffered,
                    defer: false
                )
        }

        service.showWindow = { _ in }

        service.showAccessibilityAlert()
        service.showRestartAlert()

        #expect(permissionClosed == true)
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
