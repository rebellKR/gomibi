//
//  gomiDayWidgetBundle.swift
//  gomiDayWidget
//
//  Created by hyun_kim on 2026/11/23.
//

import WidgetKit
import SwiftUI

@main
struct gomiDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleGomiWidget()  // 간단한 위젯
    }
}
// MARK: - 간단한 위젯 구현

struct SimpleGomiWidget: Widget {
    let kind: String = "SimpleGomiWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            SimpleWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ゴミ収集日")
        .description("次のゴミ収集日を表示します")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Provider

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), nextType: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), nextType: .burnable)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // 설정 로드
        let settings = AppGroupStorage.loadSettings() ?? UserSettings()
        
        var nextType: GarbageType? = nil
        
        // 지역이 등록되어 있으면 다음 일정 계산
        if let area = settings.selectedArea {
            let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
            nextType = engine.getNextSchedule()?.garbageType
        }
        
        let entry = SimpleEntry(date: Date(), nextType: nextType)
        
        // 1시간 후 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nextType: GarbageType?
}

// MARK: - View

struct SimpleWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SimpleEntry
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangularView
        case .accessoryCircular:
            circularView
        case .accessoryInline:
            inlineView
        default:
            Text("GomiDay")
        }
    }
    
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let type = entry.nextType {
                HStack(spacing: 6) {
                    Text("次")
                        .font(.system(size: 14, weight: .bold))
                    Text(type.shortName)
                        .font(.system(size: 16, weight: .bold))
                }
            } else {
                Text("地域未登録")
                    .font(.system(size: 14))
            }
        }
        .widgetAccentable()
    }
    
    private var circularView: some View {
        VStack(spacing: 2) {
            if let type = entry.nextType {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                Text("次")
                    .font(.system(size: 10))
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 18))
            }
        }
        .widgetAccentable()
    }
    
    private var inlineView: some View {
        if let type = entry.nextType {
            Text("次 \(type.shortName)")
        } else {
            Text("地域を登録")
        }
    }
}

