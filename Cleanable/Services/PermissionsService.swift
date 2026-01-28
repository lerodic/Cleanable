import AppKit
import Foundation
import SwiftUI

class PermissionsService: @unchecked Sendable {
    static let accessibilitySettingsUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    
    var hasAccessibilityPermissions: () -> Bool = {
        AXIsProcessTrusted()
    }
    
    var openWorkspace: (URL) -> Void = { url in
        NSWorkspace.shared.open(url)
    }
    
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
    
    private var permissionWindow: NSWindow?
    
    func requestPermissions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.hasAccessibilityPermissions() {
                self.showAccessibilityAlert()
            }
        }
    }
    
    func showAccessibilityAlert() {
        if permissionWindow == nil {
            permissionWindow = createPermissionWindow()
        }
        
        guard let window = permissionWindow else { return }
        
        showWindow(window)
    }
    
    private func createPermissionWindow() -> NSWindow {
        let window = createWindow(
            NSRect(x: 0, y: 0, width: 480, height: 400),
            [.titled, .closable],
            "Permission Required"
        )
        
        let permissionView = AccessibilityPermissionView(
            onOpenSettings: { [weak self] in
                self?.openSettingsPanel(at: PermissionsService.accessibilitySettingsUrl)
                self?.permissionWindow?.close()
            }, onDismiss: { [weak self] in
                self?.permissionWindow?.close()
            }
        )
        
        window.contentView = NSHostingView(rootView: permissionView)
        
        return window
    }
    
    func openSettingsPanel(at urlSchema: String) {
        guard let url = URL(string: urlSchema) else { return }
        
        if isValidSettingsURL(url) {
            openWorkspace(url)
        }
    }
    
    private func isValidSettingsURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: "x-apple.systempreferences")
    }
}
