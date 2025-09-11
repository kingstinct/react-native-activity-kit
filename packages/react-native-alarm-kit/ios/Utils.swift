import AlarmKit
import NitroModules

@available(iOS 26.0, *)
func convertAuthStatus(_ status: AlarmManager.AuthorizationState) -> AuthStatus {
    switch status {
    case .authorized:
        return .authorized
    case .denied:
        return .denied
    case .notDetermined:
        return .notdetermined
    @unknown default:
        return .notdetermined
    }
}

@available(iOS 26.0, *)
func convertAlarmState(_ status: Alarm.State) -> AlarmState {
    switch status {
    case .alerting:
        return .alerting
    case .countdown:
        return .countdown
    case .paused:
        return .paused
    case .scheduled:
        return .scheduled
    @unknown default:
        fatalError("unknown alarm state")
    }
}
