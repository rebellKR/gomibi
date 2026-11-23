//
//  gomiDayWidgetLiveActivity.swift
//  gomiDayWidget
//
//  Created by hyun_kim on 2026/11/23.
//
//  ⚠️ Live Activity는 사용하지 않습니다. 주석 처리됨.

/*
import ActivityKit
import WidgetKit
import SwiftUI

struct gomiDayWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct gomiDayWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: gomiDayWidgetAttributes.self) { context in
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
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension gomiDayWidgetAttributes {
    fileprivate static var preview: gomiDayWidgetAttributes {
        gomiDayWidgetAttributes(name: "World")
    }
}

extension gomiDayWidgetAttributes.ContentState {
    fileprivate static var smiley: gomiDayWidgetAttributes.ContentState {
        gomiDayWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: gomiDayWidgetAttributes.ContentState {
         gomiDayWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: gomiDayWidgetAttributes.preview) {
   gomiDayWidgetLiveActivity()
} contentStates: {
    gomiDayWidgetAttributes.ContentState.smiley
    gomiDayWidgetAttributes.ContentState.starEyes
}
*/
