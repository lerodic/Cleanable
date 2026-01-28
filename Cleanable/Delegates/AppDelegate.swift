import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var permissionsService: PermissionsService
    private var viewModelFactory: () -> LockViewModel
    
    private(set) var statusItem: NSStatusItem?
    private var viewModel: LockViewModel?
    private var shortcutWindow: NSWindow?
    
    var distributedNotificationCenter: DistributedNotificationCenter {
        DistributedNotificationCenter.default()
    }
    
    override init() {
        self.permissionsService = PermissionsService()
        self.viewModelFactory = { LockViewModel() }
        super.init()
    }
    
    convenience init(
        permissionsService: PermissionsService = PermissionsService(),
        viewModelFactory: @escaping () -> LockViewModel = { LockViewModel() }
    ) {
        self.init()
        self.permissionsService = permissionsService
        self.viewModelFactory = viewModelFactory
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupApplication()
        createStatusItem()
        
        if permissionsService.hasAccessibilityPermissions() {
            initializeViewModel()
            setupMenu()
        } else {
            permissionsService.requestPermissions()
            observeAccessibilityChanges()
        }
    }
    
    private func setupApplication() {
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        updateStatusBarIcon(isLocked: false)
    }
    
    private func updateStatusBarIcon(isLocked: Bool) {
        guard let button = statusItem?.button else { return }
        
        let iconName = isLocked ? "lock.fill" : "lock.open.fill"
        
        button.image = NSImage(
            systemSymbolName: iconName,
            accessibilityDescription: isLocked ? "Keyboard is locked" : "Keyboard unlocked"
        )
        button.image?.isTemplate = true
    }
    
    private func initializeViewModel() {
        viewModel = viewModelFactory()
        
        viewModel?.onStateChange = { [weak self] isLocked in
            self?.updateMenu(isLocked: isLocked)
        }
    }
    
    private func updateMenu(isLocked: Bool) {
        guard let menu = statusItem?.menu else { return }
        
        if let toggleItem = menu.items.first(where: { $0.action == #selector(toggleLock) }) {
            toggleItem.title = isLocked ? "Unlock keyboard" : "Lock keyboard"
        }
        
        updateStatusBarIcon(isLocked: isLocked)
    }
    
    @objc func toggleLock() {
        viewModel?.toggleLock()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        for (index, menuItem) in makeMenuItems().enumerated() {
            if index < 2 {
                menuItem.target = self
            }
            
            menu.addItem(menuItem)
        }
        
        statusItem?.menu = menu
    }
    
    private func makeMenuItems() -> [NSMenuItem] {
        [
            NSMenuItem(
                title: "Lock keyboard",
                action: #selector(toggleLock),
                keyEquivalent: ""
            ),
            NSMenuItem(
                title: "Configure shortcut...",
                action: #selector(openShortcutSettings),
                keyEquivalent: ","
            ),
            NSMenuItem.separator(),
            NSMenuItem(
                title: "Quit Cleanable",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
        ]
    }
    
    @objc private func openShortcutSettings() {
        if shortcutWindow == nil {
            createShortcutWindow()
        }
        
        shortcutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func createShortcutWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Configure shortcut"
        window.center()
        window.isReleasedWhenClosed = false
        
        if let viewModel = viewModel {
            let settingsView = ShortcutSettingsView(viewModel: viewModel)
            
            window.contentView = NSHostingView(rootView: settingsView)
        }
        
        shortcutWindow = window
    }
    
    func observeAccessibilityChanges() {
        distributedNotificationCenter.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: NSNotification.Name("com.apple.accessibility.api"),
            object: nil
        )
    }
    
    @objc private func accessibilitySettingsChanged() {
        if permissionsService.hasAccessibilityPermissions() {
            distributedNotificationCenter.removeObserver(
                self,
                name: NSNotification.Name("com.apple.accessibility.api"),
                object: nil
            )
            
            initializeViewModel()
            setupMenu()
        }
    }
}
