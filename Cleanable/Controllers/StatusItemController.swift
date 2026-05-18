import AppKit

class StatusItemController {
    private let statusItem: NSStatusItem
    private(set) var menu: NSMenu?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon(isLocked: false)
    }
    
    private func updateIcon(isLocked: Bool) {
        guard let button = statusItem.button else { return }
        
        let iconName = isLocked ? "lock.fill" : "lock.open.fill"
        
        button.image = NSImage(
            systemSymbolName: iconName,
            accessibilityDescription: isLocked ? "Input is disabled" : "Input is enabled"
        )
        button.image?.isTemplate = true
    }
    
    func setupMenu(
        onToggleLock: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        let menu = MenuFactory.make(onToggleLock: onToggleLock, onOpenSettings: onOpenSettings)
        
        statusItem.menu = menu
        self.menu = menu
    }
    
    func update(isLocked: Bool) {
        updateIcon(isLocked: isLocked)
        updateToggleTitle(isLocked: isLocked)
    }
    
    private func updateToggleTitle(isLocked: Bool) {
        guard let menu else { return }
        
        menu.items.first?.title = isLocked ? "Enable input" : "Disable input"
    }
    
    func frame() -> CGRect? {
        guard let button = statusItem.button, let window = button.window else { return nil }
        
        return window.convertToScreen(button.convert(button.bounds, to: nil))
    }
}
