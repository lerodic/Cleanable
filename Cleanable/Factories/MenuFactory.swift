import AppKit
import ObjectiveC

struct MenuFactory {
    static func make(
        onToggleLock: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) -> NSMenu {
        let menu = NSMenu()
        
        for item in makeMenuItems(onToggleLock: onToggleLock, onOpenSettings: onOpenSettings) {
            menu.addItem(item)
        }
        
        return menu
    }
    
    private static func makeMenuItems(
        onToggleLock: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) -> [NSMenuItem] {
        [
            makeToggleItem(onToggleLock: onToggleLock),
            makeSettingsItem(onOpenSettings: onOpenSettings),
            .separator(),
            makeQuitItem()
        ]
    }
    
    private static func makeToggleItem(onToggleLock: @escaping () -> Void) -> NSMenuItem {
        let toggle = NSMenuItem(
            title: "Disable input",
            action: nil,
            keyEquivalent: ""
        )
        toggle.actionHandler = onToggleLock
        
        return toggle
    }
    
    private static func makeSettingsItem(onOpenSettings: @escaping () -> Void) -> NSMenuItem {
        let settings = NSMenuItem(
            title: "Configure shortcut...",
            action: nil,
            keyEquivalent: ","
        )
        settings.actionHandler = onOpenSettings
        
        return settings
    }
    
    private static func makeQuitItem() -> NSMenuItem {
        let quit = NSMenuItem(
            title: "Quit Cleanable",
            action: nil,
            keyEquivalent: "q"
        )
        quit.actionHandler = { NSApp.terminate(nil) }
        
        return quit
    }
}

extension NSMenuItem {
    private enum AssociatedKeys {
        static var actionHandler: UInt8 = 0
    }
    
    var actionHandler: (() -> Void)? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.actionHandler) as? () -> Void }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.actionHandler,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            target = self
            action = #selector(invokeActionHandler)
        }
    }
    
    @objc private func invokeActionHandler() {
        actionHandler?()
    }
}
