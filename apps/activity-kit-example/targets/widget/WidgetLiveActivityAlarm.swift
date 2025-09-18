import ActivityKit
import AlarmKit
import WidgetKit
import SwiftUI
import NitroActivityKitCore

@available(iOS 26.0, *)
func getAlarmTimeInterval() -> Date {
  do {
    let addInterval = try AlarmManager.shared.alarms.first(where: { alarm in
      alarm.state == .countdown
    })?.countdownDuration?.preAlert ?? 10

    let now = Date(timeIntervalSinceNow: addInterval)

    // now.addTimeInterval(addInterval)

    return now
  } catch {
    print("AlarmKit: failed to fetch countdown alarm — \(error)")
    return Date(timeIntervalSinceNow: 20)
  }

}

@available(iOS 26.0, *)
struct WidgetLiveActivityAlarm: Widget {

  var body: some WidgetConfiguration {

        ActivityConfiguration(
          for: AlarmAttributes<GenericDictionaryAlarmStruct>.self) { context in
            // Changed VStack to mimic built-in timer style
            ZStack {
              /*RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)*/
// context.state.mode <- for checking state
              HStack(spacing: 8) {
                Text("Timer")
                  .font(.subheadline.weight(.medium))
                  // .glassEffect(.tint(.orange))
                  .foregroundColor(.secondary)

                Text(context.attributes.metadata?.getDate("timerFiringAt") ?? Date(),
                     style: .timer)
                  .font(.system(size: 36, weight: .medium, design: .monospaced))
                  .foregroundColor(.orange)
                  .minimumScaleFactor(0.5)
                  // .glassEffect(.tint(.orange))
                  .lineLimit(1)
              }
              .padding()
              .activityBackgroundTint(Color.black.opacity(0.1))
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(16)
            .activityBackgroundTint(Color.black.opacity(0.1))
            .containerBackground(.ultraThinMaterial, for: .widget)
            // .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
          DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
              Text("Leading")
                .glassEffect()
            }
            DynamicIslandExpandedRegion(.trailing) {
              Text("Trailing")
                .glassEffect()
            }
            DynamicIslandExpandedRegion(.center) {
              ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                  .fill(.ultraThinMaterial)

                HStack(spacing: 8) {
                  Text("Timer")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .glassEffect()
                  Text(context.attributes.metadata?.getDate("timerFiringAt") ?? Date(),
                       style: .timer,
                  )
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .foregroundColor(.orange)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .glassEffect()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
              .padding(16)
            }
          } compactLeading: {
            Text("L")
              .glassEffect()
          } compactTrailing: {
            Text("Hello")
              .glassEffect()
          } minimal: {
            Text("Hello")
              .glassEffect()
          }
          .widgetURL(URL(string: "https://www.expo.dev"))
          .keylineTint(Color.red)
        }
    }
}
