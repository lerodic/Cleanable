import AppKit
@testable import Cleanable
import Foundation
import Testing

@MainActor
@Suite("AppDelegate Tests", .serialized)
struct AppDelegateTests {
    final class MockPermissionsService: PermissionsService, @unchecked Sendable {
        var hasPermissions = false
        var requestPermissionsCalled = false

        override init() {
            super.init()

            hasAccessibilityPermissions = { [weak self] in
                self?.hasPermissions ?? false
            }
        }

        override func requestPermissions() {
            requestPermissionsCalled = true
        }
    }

    final class MockLockViewModel: LockViewModel, @unchecked Sendable {
        var toggleLockCalled = false
        private(set) var simulatedIsLocked = false

        override init() {}

        override func toggleLock() {
            toggleLockCalled = true
            simulatedIsLocked.toggle()
            onStateChange?(simulatedIsLocked)
        }
    }

    @Test("Sets activation policy to 'accessory' on launch")
    func setActivationPolicyToAccessory() {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let delegate = AppDelegate(permissionsService: mockService)
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        #expect(NSApp.activationPolicy() == .accessory)
    }

    @Test("Requests permissions when not already granted on launch")
    func launchWithoutPermissions() {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = false

        let delegate = AppDelegate(permissionsService: mockService)
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        #expect(mockService.requestPermissionsCalled == true)
    }

    @Test("Launches normally when permissions have not been granted on launch")
    func launchWithPermissions() {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let delegate = AppDelegate(permissionsService: mockService)
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        #expect(mockService.requestPermissionsCalled == false)
    }

    @Test("Correctly builds and initializes menu")
    func buildAndInitMenu() throws {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let delegate = AppDelegate(permissionsService: mockService)
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        let menu = try #require(delegate.statusItem?.menu)

        #expect(menu.items[0].title == "Lock keyboard")
        #expect(menu.items[1].title == "Configure shortcut...")
        #expect(menu.items[2].isSeparatorItem)
        #expect(menu.items[3].title == "Quit Cleanable")
    }

    @Test("Updates menu when lock state changes")
    func updateMenuOnLockStateChange() throws {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let mockViewModel = MockLockViewModel()

        let delegate = AppDelegate(permissionsService: mockService, viewModelFactory: { mockViewModel })
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        let menu = try #require(delegate.statusItem?.menu)
        let toggleItem = try #require(
            menu.items.first { $0.action == #selector(AppDelegate.toggleLock) }
        )

        #expect(toggleItem.title == "Lock keyboard")

        mockViewModel.toggleLock()

        #expect(toggleItem.title == "Unlock keyboard")
    }

    @Test("Toggles lock when tapping on menu item")
    func toggleLockOnMenuItemTap() {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let mockViewModel = MockLockViewModel()

        let delegate = AppDelegate(permissionsService: mockService, viewModelFactory: { mockViewModel })
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)
        
        delegate.perform(#selector(AppDelegate.toggleLock))
        
        #expect(mockViewModel.toggleLockCalled)
    }
}
