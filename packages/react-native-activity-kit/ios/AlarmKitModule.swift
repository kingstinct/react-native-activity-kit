import AlarmKit
import SwiftUI
import NitroModules

@available(iOS 26.0, *)
class AlarmKitModule: HybridAlarmKitModuleSpec {
    func requestAuthorization() throws -> NitroModules.Promise<AuthStatus> {
        return Promise.async {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    let result = try await AlarmManager.shared.requestAuthorization()

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

    func createCountdown(alertTitle: String, stopText: String, countdownTitle: String) -> Promise<any HybridAlarmSpec> {
        let stopButton = AlarmButton(
            text: LocalizedStringResource(stringLiteral: stopText),
            textColor: Color.black,
            systemImageName: "stop.circle"
        )

        let secondaryButton = AlarmButton(
            text: LocalizedStringResource(stringLiteral: stopText),
            textColor: Color.black,
            systemImageName: "stop.circle"
        )

        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: alertTitle),
            stopButton: stopButton,
            // secondaryButton: secondaryButton,
            // secondaryButtonBehavior: .none
        )

        let pauseButton = AlarmButton(
            text: LocalizedStringResource(stringLiteral: stopText),
            textColor: Color.black,
            systemImageName: "pause.circle"
        )

        let resumeButton = AlarmButton(
            text: LocalizedStringResource(stringLiteral: stopText),
            textColor: Color.black,
            systemImageName: "play.circle"
        )

        let countdownContent = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: countdownTitle),
            pauseButton: pauseButton
        )

        let pausedContent = AlarmPresentation.Paused(
            title: "Paused",
            resumeButton: resumeButton
        )

        let presentation = AlarmPresentation(
            alert: alertContent,
            // countdown: countdownContent,
            // paused: pausedContent
        )
        // presentation.alert.secondaryButtonBehavior = .none

        let id = UUID()

        let countdownDuration: Double = TimeInterval(floatLiteral: 60)

        let attributes = AlarmAttributes<GenericDictionaryAlarmStruct>.init(
            presentation: presentation,
            metadata: try? GenericDictionaryAlarmStruct(state: [:]),
            tintColor: .black
        )

        let alarmConfiguration = AlarmManager.AlarmConfiguration(
            /*countdownDuration: Alarm.CountdownDuration.init(
                preAlert: countdownDuration,
                postAlert: countdownDuration
            ),*/
            schedule: Alarm.Schedule.fixed(Date.now.addingTimeInterval(countdownDuration)),
            attributes: attributes,
            // stopIntent: Intent.unspecified (alarmID: id),
            // secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput)
            sound: .default
        )

        return Promise.async {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    do {
                        let alarm = try await AlarmManager.shared.schedule(
                            id: id,
                            configuration: alarmConfiguration
                        )
                        let alarmModule = AlarmModule(alarm: alarm)
                        continuation.resume(returning: alarmModule)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
