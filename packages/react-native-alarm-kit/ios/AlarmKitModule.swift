import AlarmKit
import NitroModules

@available(iOS 26.0, *)
class AlarmKitModule: HybridAlarmKitModuleSpec {
    func requestAuthorization() throws -> NitroModules.Promise<AuthStatus> {
        return Promise.async {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    var result = try await AlarmManager.shared.requestAuthorization()

                    continuation.resume(returning: convertAuthStatus(result))
                }
            }
        }
    }

    func getPermissionStatus() throws -> AuthStatus {
        return convertAuthStatus(AlarmManager.shared.authorizationState)
    }

    func authorizationUpdates(callback: @escaping (AuthStatus) -> Void) throws {
        Task {
            for await status in AlarmManager.shared.authorizationUpdates {
                callback(convertAuthStatus(status))
            }
        }
    }

    func alarmUpdates(callback: @escaping ([any HybridAlarmSpec]) -> Void) throws {
        Task {
            for await alarms in AlarmManager.shared.alarmUpdates {
                callback(alarms.map { alarm in
                    return AlarmModule(alarm: alarm)
                })
            }
        }
    }

    func alarms() throws -> [any HybridAlarmSpec] {
        return try AlarmManager.shared.alarms.map { alarm in
            return AlarmModule(alarm: alarm)
        }
    }
}
