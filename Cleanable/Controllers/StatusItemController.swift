import AppKit

class StatusItemController {
    private let statusItem: NSStatusItem
    private(set) var menu: NSMenu?
    private(set) var isMenuOpen = false
    
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
        
        setupListeners(for: menu)
        
        statusItem.menu = menu
        self.menu = menu
    }
    
    private func setupListeners(for menu: NSMenu) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(menuDidOpen),
            name: NSMenu.didBeginTrackingNotification,
            object: menu
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(menuDidClose),
            name: NSMenu.didEndTrackingNotification,
            object: menu
        )
    }
    
    @objc private func menuDidOpen() {
        isMenuOpen = true
    }
    
    @objc private func menuDidClose() {
        isMenuOpen = false
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
