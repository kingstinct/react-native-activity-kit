import AlarmKit
import SwiftUI
import NitroModules

func createColor(_ color: RGBColor) -> Color {
    return Color.init(red: color.red, green: color.green, blue: color.blue)
}

@available(iOS 26.0, *)
func createAlarmButtonNullable(_ props: AlarmButtonProps?) -> AlarmButton? {
    if let props = props {
        return createAlarmButton(props)
    }

    return nil
}

@available(iOS 26.0, *)
func createAlarmButton(_ props: AlarmButtonProps) -> AlarmButton {
    return AlarmButton(
        text: LocalizedStringResource(stringLiteral: props.text),
        textColor: createColor(props.textColor),
        systemImageName: props.systemImageName
    )
}

@available(iOS 26.0, *)
class AlarmKitModule: HybridAlarmKitModuleSpec {
    func createCountdown(props: CountdownProps) throws -> NitroModules.Promise<any HybridAlarmSpec> {
        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: props.alert.title),
            stopButton: createAlarmButton(props.alert.stopButton),
        )

        let countdownContent = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: props.countdown.title),
            pauseButton: createAlarmButtonNullable(props.countdown.pauseButton),
        )

        var pausedPresentation: AlarmPresentation.Paused?

        if let paused = props.paused {
            pausedPresentation = AlarmPresentation.Paused(
                title: "Paused",
                resumeButton: createAlarmButton(paused.resumeButton),
            )
        }

        let presentation = AlarmPresentation(
            alert: alertContent,
            countdown: countdownContent,
            paused: pausedPresentation
        )

        let id = UUID()

        let preAlert = TimeInterval(floatLiteral: props.preAlert)
        let postAlert = props.postAlert != nil ? TimeInterval(floatLiteral: props.postAlert!) : nil

        let attributes = AlarmAttributes<GenericDictionaryAlarmStruct>.init(
            presentation: presentation,
            metadata: try? GenericDictionaryAlarmStruct(state: anyMapToDictionary(props.metadata)),
            tintColor: createColor(props.tintColor)
        )

        let alarmConfiguration = AlarmManager.AlarmConfiguration(
            countdownDuration: Alarm.CountdownDuration.init(
                preAlert: preAlert,
                postAlert: postAlert
            ),
            // schedule: Alarm.Schedule.fixed(Date.now.addingTimeInterval(countdownDuration)),
            attributes: attributes,
            // stopIntent: Intent.unspecified (alarmID: id),
            // secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput)
            sound: props.sound != nil ? .named(props.sound!) : .default
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

    func createAlarm(props: AlarmProps) throws -> NitroModules.Promise<any HybridAlarmSpec> {
        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: props.alert.title),
            stopButton: createAlarmButton(props.alert.stopButton),
        )

        var pausedPresentation: AlarmPresentation.Paused?

        if let paused = props.paused {
            pausedPresentation = AlarmPresentation.Paused(
                title: "Paused",
                resumeButton: createAlarmButton(paused.resumeButton),
            )
        }

        let presentation = AlarmPresentation(
            alert: alertContent,
            paused: pausedPresentation
        )

        let id = UUID()

        let attributes = AlarmAttributes<GenericDictionaryAlarmStruct>.init(
            presentation: presentation,
            metadata: try? GenericDictionaryAlarmStruct(state: anyMapToDictionary(props.metadata)),
            tintColor: createColor(props.tintColor)
        )

        let alarmConfiguration = AlarmManager.AlarmConfiguration(
            schedule: Alarm.Schedule.fixed(props.scheduledDate),
            attributes: attributes,
            // stopIntent: Intent.unspecified (alarmID: id),
            // secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput)
            sound: props.sound != nil ? .named(props.sound!) : .default
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
}
