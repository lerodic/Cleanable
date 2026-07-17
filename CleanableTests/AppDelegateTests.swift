import AppKit
@testable import Cleanable
import Foundation
import Testing

@MainActor
@Suite("AppDelegate Tests", .serialized)
struct AppDelegateTests {
    @MainActor
    final class MockPermissionsService: PermissionsService, @unchecked Sendable {
        var hasPermissions = false
        var requestPermissionsCalled = false
        var showRestartAlertCalled = false

        init(hasPermissions: Bool = false) {
            self.hasPermissions = hasPermissions
            super.init(presenter: WindowPresenter())

            hasAccessibilityPermissions = { [weak self] in
                self?.hasPermissions ?? false
            }
        }

        override func requestPermissions() {
            MainActor.assumeIsolated {
                requestPermissionsCalled = true
            }
        }

        override func showRestartAlert() {
            MainActor.assumeIsolated {
                showRestartAlertCalled = true
            }
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

    final class FakeTimerScheduler: TimerScheduler {
        var capturedBlock: ((Timer) -> Void)?
        var scheduleCalled = false

        func schedule(
            interval: TimeInterval,
            repeats: Bool,
            _ block: @escaping (Timer) -> Void
        ) -> Timer {
            scheduleCalled = true
            capturedBlock = block

            return Timer()
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

        let menu = try #require(delegate.statusItemMenu)

        #expect(menu.items[0].title == "Disable input")
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

        let menu = try #require(delegate.statusItemMenu)

        #expect(menu.items[0].title == "Disable input")

        mockViewModel.toggleLock()

        #expect(menu.items[0].title == "Enable input")
    }

    @Test("Toggles lock when tapping on menu item")
    func toggleLockOnMenuItemTap() throws {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let mockViewModel = MockLockViewModel()

        let delegate = AppDelegate(permissionsService: mockService, viewModelFactory: { mockViewModel })
        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        let toggleItem = try #require(delegate.statusItemMenu?.items.first)
        toggleItem.actionHandler?()

        #expect(mockViewModel.toggleLockCalled)
    }

    @Test("Starts accessibility polling when permissions have not been granted")
    func startPolling() {
        let mockService = MockPermissionsService(hasPermissions: false)

        let fakeScheduler = FakeTimerScheduler()

        let delegate = AppDelegate(
            permissionsService: mockService,
            timerScheduler: fakeScheduler
        )
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        #expect(fakeScheduler.scheduleCalled)
        #expect(fakeScheduler.capturedBlock != nil)
    }

    @Test("Shows restart alert after permissions have been granted")
    func showRestartAlertAfterPermissionsHaveBeenGranted() {
        let mockService = MockPermissionsService(hasPermissions: false)

        let fakeScheduler = FakeTimerScheduler()

        let delegate = AppDelegate(
            permissionsService: mockService,
            timerScheduler: fakeScheduler
        )
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        delegate.applicationDidFinishLaunching(notification)

        mockService.hasPermissions = true

        fakeScheduler.capturedBlock?(Timer())

        #expect(mockService.showRestartAlertCalled)
    }
    
    @Test("Status item frame provider is wired to status item controller")
    func statusItemFrameProviderIsWired() throws {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let mockViewModel = MockLockViewModel()

        let delegate = AppDelegate(permissionsService: mockService, viewModelFactory: { mockViewModel })
        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        _ = mockViewModel.statusItemFrameProvider?()
        
        #expect(mockViewModel.statusItemFrameProvider != nil)
    }

    @Test("Status item interaction provider reflects menu open state")
    func statusItemInteractionProviderReflectsMenuOpenState() throws {
        let mockService = MockPermissionsService()
        mockService.hasPermissions = true

        let mockViewModel = MockLockViewModel()

        let delegate = AppDelegate(permissionsService: mockService, viewModelFactory: { mockViewModel })
        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        #expect(mockViewModel.statusItemInteractionProvider != nil)
        #expect(mockViewModel.statusItemInteractionProvider?() == false)
    }
}
