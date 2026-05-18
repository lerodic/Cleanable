import AppKit

protocol TrackpadMonitorDelegate: AnyObject {
    func trackpadMonitor(_ monitor: TrackpadMonitor, shouldBlockEvent event: NSEvent) -> Bool
    func trackpadMonitorStatusItemFrame(_ monitor: TrackpadMonitor) -> CGRect?
    func trackpadMonitorIsStatusItemInteractive(_ monitor: TrackpadMonitor) -> Bool
}
