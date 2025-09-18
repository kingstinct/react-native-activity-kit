import WidgetKit
import SwiftUI

@main
struct exportWidgets: WidgetBundle {
      @WidgetBundleBuilder
      var body: some Widget {
          widgets()
      }

      private func widgets() -> some Widget {
          if #available(iOS 26, *) {
              return WidgetBundleBuilder.buildBlock( widget(),
                                                     // widgetControl(),
                                                     WidgetLiveActivity(),
                                                   WidgetLiveActivityAlarm())
          } else {
              return WidgetBundleBuilder.buildBlock( widget(),
                                                     // widgetControl(),
                                                     WidgetLiveActivity())
          }
      }
}
