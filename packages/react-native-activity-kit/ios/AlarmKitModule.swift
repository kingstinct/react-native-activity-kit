import AlarmKit
import SwiftUI
import NitroModules

func createColor(_ color: RGBColor) -> Color {
    if let alpha = color.alpha {
        return Color.init(
            red: color.red * 255,
            green: color.green * 255,
            blue: color.blue * 255,
            opacity: alpha
        )
    }
    return Color.init(
        red: color.red * 255,
        green: color.green * 255,
        blue: color.blue * 255
    )
}

func createPausedPresentation(_ paused: PausedPresentation?) -> AlarmPresentation.Paused? {
    if let paused = paused {
        return AlarmPresentation.Paused(
            title: LocalizedStringResource(stringLiteral: paused.title),
            resumeButton: createAlarmButton(paused.resumeButton),
        )
    }

    return nil
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

func createSecondButtonBehavior(_ behavior: SecondaryButtonBehavior?) -> AlarmPresentation.Alert.SecondaryButtonBehavior? {
    if let behavior = behavior {

        switch behavior {
        case .countdown:
            return .countdown
        case .custom:
            return .custom
        case .none:
            return .none
        }
    }
    return nil
}

func createAlertPresentation(_ alertPresentation: AlertPresentation) -> AlarmPresentation.Alert {
    let alertContent = AlarmPresentation.Alert(
        title: LocalizedStringResource(stringLiteral: alertPresentation.title),
        stopButton: createAlarmButton(alertPresentation.stopButton),
        secondaryButton: createAlarmButtonNullable(alertPresentation.secondaryButton),
        secondaryButtonBehavior: createSecondButtonBehavior(alertPresentation.secondaryButtonBehavior)
    )

    return alertContent
}

func scheduleAlarm(alarmConfiguration: AlarmManager.AlarmConfiguration<GenericDictionaryAlarmStruct>) -> Promise<any HybridAlarmProxySpec> {
    return Promise.async {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let id = UUID()
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

func createAttributes(presentation: AlarmPresentation, metadata: AnyMap, tintColor: RGBColor) -> AlarmAttributes<GenericDictionaryAlarmStruct> {

    let attributes = AlarmAttributes<GenericDictionaryAlarmStruct>.init(
        presentation: presentation,
        metadata: try? GenericDictionaryAlarmStruct(state: anyMapToDictionary(metadata)),
        tintColor: createColor(tintColor)
    )

    return attributes
}

@available(iOS 26.0, *)
class AlarmKitModule: HybridAlarmKitModuleSpec {
    func createCountdown(props: CountdownProps) throws -> Promise<any HybridAlarmProxySpec> {
        let alertContent = createAlertPresentation(props.alert)

        let countdownContent = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: props.countdown.title),
            pauseButton: createAlarmButtonNullable(props.countdown.pauseButton),
        )

        let pausedPresentation = createPausedPresentation(props.paused)

        let presentation = AlarmPresentation(
            alert: alertContent,
            countdown: countdownContent,
            paused: pausedPresentation
        )

        let attributes = createAttributes(
            presentation: presentation,
            metadata: props.metadata,
            tintColor: props.tintColor
        )

        let preAlert = TimeInterval(floatLiteral: props.preAlert)
        let postAlert = props.postAlert != nil ? TimeInterval(floatLiteral: props.postAlert!) : nil

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

        return scheduleAlarm(alarmConfiguration: alarmConfiguration)
    }

    func createAlarm(props: AlarmProps) throws -> NitroModules.Promise<any HybridAlarmProxySpec> {
        let alertContent = createAlertPresentation(props.alert)

        let pausedPresentation = createPausedPresentation(props.paused)

        let presentation = AlarmPresentation(
            alert: alertContent,
            paused: pausedPresentation
        )

        let attributes = createAttributes(
            presentation: presentation,
            metadata: props.metadata,
            tintColor: props.tintColor
        )

        let alarmConfiguration = AlarmManager.AlarmConfiguration(
            schedule: Alarm.Schedule.fixed(props.scheduledDate),
            attributes: attributes,
            // stopIntent: Intent.unspecified (alarmID: id),
            // secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput)
            sound: props.sound != nil ? .named(props.sound!) : .default
        )

        return scheduleAlarm(alarmConfiguration: alarmConfiguration)
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

    func alarmUpdates(callback: @escaping ([any HybridAlarmProxySpec]) -> Void) throws {
        Task {
            for await alarms in AlarmManager.shared.alarmUpdates {
                callback(alarms.map { alarm in
                    return AlarmModule(alarm: alarm)
                })
            }
        }
    }

    func alarms() throws -> [any HybridAlarmProxySpec] {
        return try AlarmManager.shared.alarms.map { alarm in
            return AlarmModule(alarm: alarm)
        }
    }
}
