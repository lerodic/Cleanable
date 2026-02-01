import AppKit
import Foundation
import SwiftUI

class PermissionsService: @unchecked Sendable {
    static let accessibilitySettingsUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    
    private let presenter: WindowPresenter
    
    var hasAccessibilityPermissions: () -> Bool = {
        AXIsProcessTrusted()
    }
    
    var openWorkspace: (URL) -> Void = { url in
        NSWorkspace.shared.open(url)
    }
    
    var quitApp: () -> Void = {
        NSApp.terminate(nil)
    }
    
    var restartApp: () -> Void = {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [
            "-n",
            Bundle.main.bundlePath
        ]
        task.launch()
        
        NSApp.terminate(nil)
    }
    
    init(presenter: WindowPresenter = WindowPresenter()) {
        self.presenter = presenter
    }
    
    func requestPermissions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.hasAccessibilityPermissions() {
                self.showAccessibilityAlert()
            }
        }
    }
    
    func showAccessibilityAlert() {
        presenter.showPermissionWindow(
            onOpenSettings: { [weak self] in
                self?.openSettingsPanel(at: PermissionsService.accessibilitySettingsUrl)
                self?.presenter.closePermissionWindow()
            },
            onDismiss: { [weak self] in
                self?.presenter.closePermissionWindow()
                self?.quitApp()
            }
        )
    }
    
    func showRestartAlert() {
        presenter.closePermissionWindow()
        
        presenter.showRestartWindow(
            onRestart: { [weak self] in
                self?.restartApp()
            },
            onQuit: { [weak self] in
                self?.quitApp()
            }
        )
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
    
    func userRequestedRestart() {
        restartApp()
    }
    
    func userRequestedQuit() {
        quitApp()
    }
}
