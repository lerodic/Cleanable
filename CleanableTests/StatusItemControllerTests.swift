import AppKit
@testable import Cleanable
import Testing

@MainActor
@Suite("StatusItemController Tests", .serialized)
struct StatusItemControllerTests {
    @Test("Menu is nil before setupMenu is called")
    func menuIsNilBeforeSetup() {
        let controller = StatusItemController()

        #expect(controller.menu == nil)
    }

    @Test("setupMenu builds menu with correct items")
    func setupMenuBuildsCorrectItems() throws {
        let controller = StatusItemController()

        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        let menu = try #require(controller.menu)
        
        #expect(menu.items[0].title == "Disable input")
        #expect(menu.items[1].title == "Configure shortcut...")
        #expect(menu.items[2].isSeparatorItem)
        #expect(menu.items[3].title == "Quit Cleanable")
    }

    @Test("update changes toggle title to 'Enable input' when locked")
    func updateTitleWhenLocked() throws {
        let controller = StatusItemController()
        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        controller.update(isLocked: true)

        let menu = try #require(controller.menu)
        
        #expect(menu.items.first?.title == "Enable input")
    }

    @Test("update changes toggle title to 'Disable input' when unlocked")
    func updateTitleWhenUnlocked() throws {
        let controller = StatusItemController()
        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        controller.update(isLocked: true)
        controller.update(isLocked: false)

        let menu = try #require(controller.menu)
        
        #expect(menu.items.first?.title == "Disable input")
    }

    @Test("isMenuOpen is false before menu opens")
    func isMenuOpenInitiallyFalse() {
        let controller = StatusItemController()
        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        #expect(controller.isMenuOpen == false)
    }

    @Test("isMenuOpen becomes true when menu begins tracking")
    func isMenuOpenOnDidBeginTracking() throws {
        let controller = StatusItemController()
        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        let menu = try #require(controller.menu)
        NotificationCenter.default.post(name: NSMenu.didBeginTrackingNotification, object: menu)

        #expect(controller.isMenuOpen == true)
    }

    @Test("isMenuOpen becomes false when menu ends tracking")
    func isMenuClosedOnDidEndTracking() throws {
        let controller = StatusItemController()
        controller.setupMenu(onToggleLock: {}, onOpenSettings: {})

        let menu = try #require(controller.menu)
        NotificationCenter.default.post(name: NSMenu.didBeginTrackingNotification, object: menu)
        NotificationCenter.default.post(name: NSMenu.didEndTrackingNotification, object: menu)

        #expect(controller.isMenuOpen == false)
    }

    @Test("Toggle lock action handler is invoked")
    func toggleLockActionHandlerIsInvoked() throws {
        let controller = StatusItemController()
        var toggleLockCalled = false
        controller.setupMenu(onToggleLock: { toggleLockCalled = true }, onOpenSettings: {})

        let menu = try #require(controller.menu)
        menu.items.first?.actionHandler?()

        #expect(toggleLockCalled)
    }

    @Test("Open settings action handler is invoked")
    func openSettingsActionHandlerIsInvoked() throws {
        let controller = StatusItemController()
        var openSettingsCalled = false
        controller.setupMenu(onToggleLock: {}, onOpenSettings: { openSettingsCalled = true })

        let menu = try #require(controller.menu)
        menu.items[1].actionHandler?()

        #expect(openSettingsCalled)
    }
}
