import AlarmKit
import NitroModules

/// Thrown by alarm operations. Carries the alarm id, its state and the AlarmKit error, so the
/// JS side can tell what failed instead of getting a bare error.
struct AlarmOperationError: LocalizedError {
    let operation: String
    let id: String
    let state: String
    let underlying: Error

    var errorDescription: String? {
        return "AlarmKit \(operation) failed for alarm \(id) in state \(state): \(underlying.localizedDescription) (\(underlying))"
    }
}

@available(iOS 26.0, *)
class AlarmModule: HybridAlarmProxySpec {
    private func perform(_ operation: String, _ body: () throws -> Void) throws {
        do {
            try body()
        } catch {
            throw AlarmOperationError(operation: operation, id: id, state: state.stringValue, underlying: error)
        }
    }

    func countdown() throws {
        try perform("countdown") { try AlarmManager.shared.countdown(id: alarm.id) }
    }

    func pause() throws {
        try perform("pause") { try AlarmManager.shared.pause(id: alarm.id) }
    }

    func resume() throws {
        try perform("resume") { try AlarmManager.shared.resume(id: alarm.id) }
    }

    func stop() throws {
        try perform("stop") { try AlarmManager.shared.stop(id: alarm.id) }
    }

    /// Removes the alarm. If AlarmKit refuses a plain cancel (seen for alarms that are alerting or
    /// paused), the alarm is stopped first and cancelled again unless stopping already removed it.
    func cancel() throws {
        try perform("cancel") {
            do {
                try AlarmManager.shared.cancel(id: alarm.id)
            } catch {
                try? AlarmManager.shared.stop(id: alarm.id)
                let stillScheduled = (try? AlarmManager.shared.alarms.contains { $0.id == alarm.id }) ?? true
                if stillScheduled {
                    try AlarmManager.shared.cancel(id: alarm.id)
                }
            }
        }
    }

    private let alarm: Alarm

    var id: String {
        return alarm.id.uuidString
    }

    var state: AlarmState {
        return convertAlarmState(alarm.state)
    }

    var postAlert: Double? {
        return alarm.countdownDuration?.postAlert
    }

    var preAlert: Double? {
        return alarm.countdownDuration?.preAlert
    }

    init(alarm: Alarm) {
        self.alarm = alarm
    }
}
