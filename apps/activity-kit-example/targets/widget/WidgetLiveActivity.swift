import ActivityKit
import WidgetKit
import SwiftUI
import NitroActivityKitCore

struct WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityKitModuleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
              Text("Hello \((context.state["name"] as? String))")
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
                     Text("Bottom \(context.state["name"])")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("Hello")
            } minimal: {
              Text("Hello")
            }
            .widgetURL(URL(string: "https://www.expo.dev"))
            .keylineTint(Color.red)
        }
    }
}

extension ActivityKitModuleAttributes {
    fileprivate static var preview: ActivityKitModuleAttributes {
      do {
        return try ActivityKitModuleAttributes(data: Dictionary<String, Any>())
      } catch {
        // Fallback to empty attributes on error
        return try! ActivityKitModuleAttributes(data: Dictionary<String, Any>())
      }
    }
}

extension ActivityKitModuleAttributes.ContentState {
    fileprivate static var smiley: ActivityKitModuleAttributes.ContentState {
      do {
        return try ActivityKitModuleAttributes.ContentState(
          data: Dictionary<String, Any>()
        )
      } catch {
        // Fallback to empty content state on error
        return try! ActivityKitModuleAttributes.ContentState(data: Dictionary<String, Any>())
      }
     }
     
     fileprivate static var starEyes: ActivityKitModuleAttributes.ContentState {
       do {
         return try ActivityKitModuleAttributes.ContentState(
           data: Dictionary<String, Any>()
         )
       } catch {
         // Fallback to empty content state on error
         return try! ActivityKitModuleAttributes.ContentState(data: Dictionary<String, Any>())
       }
     }
}

#Preview("Notification", as: .content, using: ActivityKitModuleAttributes.preview) {
   WidgetLiveActivity()
} contentStates: {
  ActivityKitModuleAttributes.ContentState.smiley
  ActivityKitModuleAttributes.ContentState.starEyes
}
