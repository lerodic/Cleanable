import AppKit
import Combine
import Foundation

class PermissionsService {
    static let accessibilitySettingsUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    
    var hasAccessibilityPermissions: () -> Bool = {
        AXIsProcessTrusted()
    }
    
    var openWorkspace: (URL) -> Void = { url in
        NSWorkspace.shared.open(url)
    }
    
    var showAlert: (NSAlert) -> NSApplication.ModalResponse = { alert in
        alert.runModal()
    }
    
    func requestPermissions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.hasAccessibilityPermissions() {
                self.showAccessibilityAlert()
            }
        }
    }
    
    func showAccessibilityAlert() {
        let alert = makeAccessibilityAlert()
        
        if showAlert(alert) == .alertFirstButtonReturn {
            openSettingsPanel(at: PermissionsService.accessibilitySettingsUrl)
        }
    }
    
    func makeAccessibilityAlert() -> NSAlert {
        let alert = NSAlert()
        
        alert.messageText = "Accessibility permission required"
        alert.informativeText =
            """
            Cleanable needs Accessibility permission to monitor keyboard shortcuts
            and control keyboard input.
            
            Please enable it in:
            System Settings → Privacy & Security → Accessibility
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        
        return alert
    }
    
    private func openSettingsPanel(at urlSchema: String) {
        if let url = URL(string: urlSchema) {
            openWorkspace(url)
        }
    }
}
