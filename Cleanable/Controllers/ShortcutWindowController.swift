import AppKit
import SwiftUI

class ShortcutWindowController {
    private var window: NSWindow?
    private let viewModel: LockViewModel
    
    init(viewModel: LockViewModel) {
        self.viewModel = viewModel
    }
    
    func show() {
        if window == nil {
            window = makeWindow()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Configure shortcut"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(
            rootView: ShortcutSettingsView(viewModel: viewModel)
        )
        
        return window
    }
}
