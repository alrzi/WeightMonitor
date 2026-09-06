import Foundation
import OSLog

public extension Logger {
    static let weightMonitorSync = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "WeightMonitor",
        category: "Sync"
    )
}
