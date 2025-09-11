import AlarmKit
import NitroModules

@available(iOS 26.0, *)
class AlarmModule: HybridAlarmSpec {
    var id: String

    var state: AlarmState

    var postAlert: Double?

    var preAlert: Double?

    init(alarm: Alarm) {
        self.id = alarm.id.uuidString
        self.state = convertAlarmState(alarm.state)
        self.postAlert = alarm.countdownDuration?.postAlert
        self.preAlert = alarm.countdownDuration?.preAlert
    }
}
