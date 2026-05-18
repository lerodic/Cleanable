import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var timerScheduler: TimerScheduler
    private var permissionsService: PermissionsService
    private var viewModelFactory: () -> LockViewModel
    
    private var statusItemController: StatusItemController?
    private var shortcutWindowController: ShortcutWindowController?
    private var viewModel: LockViewModel?
    private var accessibilityPollTimer: Timer?
    
    override init() {
        self.permissionsService = PermissionsService()
        self.viewModelFactory = { LockViewModel() }
        self.timerScheduler = SystemTimerScheduler()
        super.init()
    }
    
    convenience init(
        permissionsService: PermissionsService = PermissionsService(),
        viewModelFactory: @escaping () -> LockViewModel = { LockViewModel() },
        timerScheduler: TimerScheduler = SystemTimerScheduler()
    ) {
        self.init()
        self.permissionsService = permissionsService
        self.viewModelFactory = viewModelFactory
        self.timerScheduler = timerScheduler
    }
    
    var statusItemMenu: NSMenu? {
        statusItemController?.menu
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupApplication()
        
        if permissionsService.hasAccessibilityPermissions() {
            activate()
        } else {
            permissionsService.requestPermissions()
            startAccessibilityPolling()
        }
    }
    
    private func setupApplication() {
        NSApp.setActivationPolicy(.accessory)
        statusItemController = StatusItemController()
    }
    
    private func activate() {
        viewModel = viewModelFactory()
        
        shortcutWindowController = ShortcutWindowController(viewModel: viewModel!)
        
        statusItemController?.setupMenu(
            onToggleLock: { [weak self] in self?.viewModel?.toggleLock() },
            onOpenSettings: { [weak self] in self?.shortcutWindowController?.show() }
        )
        
        viewModel!.statusItemFrameProvider = { [weak self] in
            self?.statusItemController?.frame()
        }
        
        viewModel!.statusItemInteractionProvider = { [weak self] in
            self?.statusItemController?.isMenuOpen == true
        }
        
        viewModel!.onStateChange = { [weak self] isLocked in
            self?.statusItemController?.update(isLocked: isLocked)
        }
    }
    
    func startAccessibilityPolling() {
        accessibilityPollTimer = timerScheduler.schedule(
            interval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            
            if self.permissionsService.hasAccessibilityPermissions() {
                self.accessibilityPollTimer?.invalidate()
                self.accessibilityPollTimer = nil
                
                self.permissionsService.showRestartAlert()
            }
        }
    }
}

protocol TimerScheduler {
    @discardableResult
    func schedule(
        interval: TimeInterval,
        repeats: Bool,
        _ block: @escaping (Timer) -> Void
    ) -> Timer
}

class SystemTimerScheduler: TimerScheduler {
    func schedule(interval: TimeInterval, repeats: Bool, _ block: @escaping (Timer) -> Void) -> Timer {
        Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: repeats,
            block: block
        )
    }
}
