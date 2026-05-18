import Foundation
import os.log

/// Lightweight beta diagnostics: unified os_log stream + crash breadcrumbs.
enum TribeDiagnostics {
    private static let log = Logger(subsystem: "app.tribe.app", category: "app")
    private static let crashLog = OSLog(subsystem: "app.tribe.app", category: "crash")
    private static var installed = false

    static func install() {
        guard !installed else { return }
        installed = true
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
        log.info("Tribe diagnostics ready")
    }

    private static let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        os_log(
            .fault,
            log: crashLog,
            "Uncaught %{public}@: %{public}@",
            exception.name.rawValue,
            exception.reason ?? "unknown"
        )
    }

    static func info(_ message: String) {
        log.info("\(message, privacy: .public)")
    }

    static func error(_ message: String, error: Error? = nil) {
        if let error {
            log.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        } else {
            log.error("\(message, privacy: .public)")
        }
    }
}
