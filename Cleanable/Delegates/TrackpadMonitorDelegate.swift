import AppKit

protocol TrackpadMonitorDelegate: AnyObject {
    func trackpadMonitor(_ monitor: TrackpadMonitor, shouldBlockEvent event: NSEvent) -> Bool
}
