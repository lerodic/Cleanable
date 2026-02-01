import AppKit
import SwiftUI

class WindowPresenter: @unchecked Sendable {
    private var permissionWindow: NSWindow?
    private var restartWindow: NSWindow?
    
    var createWindow: (NSRect, NSWindow.StyleMask, String) -> NSWindow = { rect, styleMask, title in
        let window = NSWindow(
            contentRect: rect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        window.title = title
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        
        return window
    }
    
    var showWindow: (NSWindow) -> Void = { window in
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    var closeWindow: (NSWindow) -> Void = { window in
        window.close()
    }
    
    func showPermissionWindow(
        onOpenSettings: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        if permissionWindow == nil {
            preparePermissionWindow(
                onOpenSettings: onOpenSettings,
                onDismiss: onDismiss
            )
        }
        
        guard let window = permissionWindow else { return }
        
        showWindow(window)
    }
    
    private func preparePermissionWindow(
        onOpenSettings: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let window = createWindow(
            NSRect(x: 0, y: 0, width: 480, height: 400),
            [.titled, .closable],
            "Permission Required"
        )
        
        let permissionView = AccessibilityPermissionView(
            onOpenSettings: onOpenSettings,
            onDismiss: onDismiss
        )
        
        window.contentView = NSHostingView(rootView: permissionView)
        
        permissionWindow = window
    }
    
    func closePermissionWindow() {
        guard let permissionWindow else { return }
        
        closeWindow(permissionWindow)
    }
    
    func showRestartWindow(
        onRestart: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        if restartWindow == nil {
            prepareRestartWindow(
                onRestart: onRestart,
                onQuit: onQuit
            )
        }
        
        guard let window = restartWindow else { return }
        
        showWindow(window)
    }
    
    private func prepareRestartWindow(
        onRestart: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        let window = createWindow(
            NSRect(x: 0, y: 0, width: 400, height: 280),
            [.titled],
            "Restart Required"
        )
        
        let restartView = RequireRestartView(
            onRestart: onRestart,
            onQuit: onQuit
        )
        
        window.contentView = NSHostingView(rootView: restartView)
        
        restartWindow = window
    }
    
    func closeRestartWindow() {
        guard let restartWindow else { return }
        
        closeWindow(restartWindow)
    }
}
