import ActivityKit
import WidgetKit
import SwiftUI
import NitroActivityKit

struct WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityKitModuleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "https://www.expo.dev"))
            .keylineTint(Color.red)
        }
    }
}

extension ActivityKitModuleAttributes {
    fileprivate static var preview: ActivityKitModuleAttributes {
        WidgetAttributes(name: "World")
    }
}

extension ActivityKitModuleAttributes.ContentState {
    fileprivate static var smiley: ActivityKitModuleAttributes.ContentState {
        WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ActivityKitModuleAttributes.ContentState {
         WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ActivityKitModuleAttributes.preview) {
   WidgetLiveActivity()
} contentStates: {
  ActivityKitModuleAttributes.ContentState.smiley
  ActivityKitModuleAttributes.ContentState.starEyes
}
