import AppKit
@testable import Cleanable
import Testing

@MainActor
@Suite("WindowPresenter Tests", .serialized)
struct WindowPresenterTests {
    @Test("Shows permission window")
    func showsPermissionWindow() {
        let service = WindowPresenter()
        var windowCreated = false
        var windowShown = false

        service.createWindow = { _, _, _ in
            windowCreated = true

            return NSWindow()
        }
        service.showWindow = { _ in
            windowShown = true
        }

        service.showPermissionWindow(onOpenSettings: {}, onDismiss: {})

        #expect(windowCreated == true)
        #expect(windowShown == true)
    }

    @Test("Closes permission window")
    func closePermissionWindow() {
        let service = WindowPresenter()
        var windowClosed = false

        service.createWindow = { _, _, _ in
            NSWindow()
        }

        service.closeWindow = { _ in
            windowClosed = true
        }

        service.showPermissionWindow(onOpenSettings: {}, onDismiss: {})
        service.closePermissionWindow()

        #expect(windowClosed == true)
    }

    @Test("Shows restart window")
    func showsRestartWindow() {
        let service = WindowPresenter()
        var windowCreated = false
        var windowShown = false

        service.createWindow = { _, _, _ in
            windowCreated = true

            return NSWindow()
        }
        service.showWindow = { _ in
            windowShown = true
        }

        service.showRestartWindow(onRestart: {}, onQuit: {})

        #expect(windowCreated == true)
        #expect(windowShown == true)
    }

    @Test("Closes restart window")
    func closeRestartWindow() {
        let service = WindowPresenter()
        var windowClosed = false

        service.createWindow = { _, _, _ in
            NSWindow()
        }

        service.closeWindow = { _ in
            windowClosed = true
        }

        service.showRestartWindow(onRestart: {}, onQuit: {})
        service.closeRestartWindow()

        #expect(windowClosed == true)
    }
}
