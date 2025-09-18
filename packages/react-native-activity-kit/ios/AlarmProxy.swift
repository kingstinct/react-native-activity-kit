import AlarmKit
import NitroModules

@available(iOS 26.0, *)
class AlarmModule: HybridAlarmProxySpec {
    func countdown() throws {
        try AlarmManager.shared.countdown(id: alarm.id)
    }

    func pause() throws {
        try AlarmManager.shared.pause(id: alarm.id)
    }

    func resume() throws {
        try AlarmManager.shared.resume(id: alarm.id)
    }

    func stop() throws {
        try AlarmManager.shared.stop(id: alarm.id)
    }

    func cancel() throws {
        try AlarmManager.shared.cancel(id: alarm.id)
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
