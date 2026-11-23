//
//  GomiDayWidget.swift
//  GomiDayWidget
//
//  Created by hyun_kim on 2026/11/22.
//
//  ⚠️ 위젯은 나중에 활성화합니다!
//  Target Membership을 설정한 후 주석을 해제하세요.


import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

/// 위젯 타임라인 제공자
struct GomiDayWidgetProvider: TimelineProvider {
    
    // 플레이스홀더 (위젯 갤러리에서 보이는 미리보기)
    func placeholder(in context: Context) -> GomiDayWidgetEntry {
        GomiDayWidgetEntry(
            date: Date(),
            nextSchedule: nil,
            tomorrowSchedule: nil
        )
    }
    
    // 위젯 갤러리에서 보이는 스냅샷
    func getSnapshot(in context: Context, completion: @escaping (GomiDayWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }
    
    // 실제 타임라인 생성
    func getTimeline(in context: Context, completion: @escaping (Timeline<GomiDayWidgetEntry>) -> Void) {
        let entry = createEntry()
        
        // 다음 업데이트 시각 계산
        let nextUpdate = calculateNextUpdateDate()
        
        // .after 정책: 지정한 시각 이후 자동 업데이트
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Private Methods
    
    /// 엔트리 생성
    private func createEntry() -> GomiDayWidgetEntry {
        // 사용자 설정 로드
        guard let settings = AppGroupStorage.loadSettings(),
              let area = settings.selectedArea else {
            return GomiDayWidgetEntry(date: Date(), nextSchedule: nil, tomorrowSchedule: nil)
        }
        
        // 엔진 생성
        let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
        
        // 다음 일정 & 내일 일정 가져오기
        let nextSchedule = engine.getNextSchedule()
        let tomorrowSchedule = engine.getTomorrowSchedule().first
        
        return GomiDayWidgetEntry(
            date: Date(),
            nextSchedule: nextSchedule,
            tomorrowSchedule: tomorrowSchedule
        )
    }
    
    /// 다음 업데이트 시각 계산
    private func calculateNextUpdateDate() -> Date {
        let settings = AppGroupStorage.loadSettings() ?? UserSettings()
        let calendar = Calendar.tokyo
        let now = Date()
        
        // 오늘의 마감 시각
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = settings.collectionDeadline.hour
        components.minute = settings.collectionDeadline.minute
        
        guard let todayDeadline = calendar.date(from: components) else {
            return calendar.date(byAdding: .hour, value: 1, to: now)!
        }
        
        // 마감 시각이 지났으면 다음날 자정, 아니면 마감 시각
        if now >= todayDeadline {
            // 다음날 자정
            return calendar.date(byAdding: .day, value: 1, to: now)!.startOfDay
        } else {
            // 오늘 마감 시각
            return todayDeadline
        }
    }
}

// MARK: - Widget Entry

/// 위젯 엔트리 (스냅샷 데이터)
struct GomiDayWidgetEntry: TimelineEntry {
    let date: Date                          // 엔트리 시각
    let nextSchedule: GarbageSchedule?      // 다음 수거 일정
    let tomorrowSchedule: GarbageSchedule?  // 내일 일정
}

// MARK: - Lock Screen Widgets

/// accessoryRectangular (직사각형)
struct LockScreenRectangularWidget: View {
    let entry: GomiDayWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let schedule = entry.nextSchedule {
                // 메인 일정
                HStack(spacing: 6) {
                    Text(schedule.displayDate())
                        .font(.system(size: 16, weight: .bold))
                    Text(schedule.garbageType.shortName)
                        .font(.system(size: 16, weight: .bold))
                }
                
                // 다음 일정 (있으면)
                if let tomorrow = entry.tomorrowSchedule,
                   !Calendar.tokyo.isDate(tomorrow.date, inSameDayAs: schedule.date) {
                    Text("\(tomorrow.date.weekdayShortName) · \(tomorrow.garbageType.shortName)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("収集なし")
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .widgetAccentable()  // iOS 16+ 액센트 색상 지원
    }
}

/// accessoryCircular (원형)
struct LockScreenCircularWidget: View {
    let entry: GomiDayWidgetEntry
    
    var body: some View {
        if let schedule = entry.nextSchedule {
            VStack(spacing: 2) {
                Image(systemName: schedule.garbageType.icon)
                    .font(.system(size: 24))
                    .widgetAccentable()
                
                Text(schedule.displayDate())
                    .font(.system(size: 11, weight: .medium))
            }
        } else {
            VStack(spacing: 2) {
                Image(systemName: "trash.slash")
                    .font(.system(size: 20))
                Text("なし")
                    .font(.system(size: 10))
            }
        }
    }
}

/// accessoryInline (한 줄)
struct LockScreenInlineWidget: View {
    let entry: GomiDayWidgetEntry
    
    var body: some View {
        if let schedule = entry.nextSchedule {
            Text("\(schedule.displayDate()) \(schedule.garbageType.shortName)")
        } else {
            Text("収集なし")
        }
    }
}

// MARK: - Widget Configuration

struct GomiDayWidget: Widget {
    let kind: String = "GomiDayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GomiDayWidgetProvider()) { entry in
            GomiDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ゴミ収集日")
        .description("次のゴミ収集日を表示します")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Widget Entry View

/// 위젯 엔트리 뷰 (WidgetFamily에 따라 다른 뷰 표시)
struct GomiDayWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: GomiDayWidgetEntry
    
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            LockScreenRectangularWidget(entry: entry)
                .containerBackground(for: .widget) {}
        case .accessoryCircular:
            LockScreenCircularWidget(entry: entry)
                .containerBackground(for: .widget) {}
        case .accessoryInline:
            LockScreenInlineWidget(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview("Rectangular", as: .accessoryRectangular) {
    GomiDayWidget()
} timeline: {
    // 오늘 일정 있음
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(
            date: Date(),
            garbageType: .burnable
        ),
        tomorrowSchedule: GarbageSchedule(
            date: Date().nextDay,
            garbageType: .resource
        )
    )
    
    // 내일 일정
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(
            date: Date().nextDay,
            garbageType: .plastic
        ),
        tomorrowSchedule: nil
    )
    
    // 일정 없음
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: nil,
        tomorrowSchedule: nil
    )
}

#Preview("Circular", as: .accessoryCircular) {
    GomiDayWidget()
} timeline: {
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(date: Date(), garbageType: .burnable),
        tomorrowSchedule: nil
    )
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(date: Date(), garbageType: .resource),
        tomorrowSchedule: nil
    )
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: nil,
        tomorrowSchedule: nil
    )
}

#Preview("Inline", as: .accessoryInline) {
    GomiDayWidget()
} timeline: {
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(date: Date(), garbageType: .burnable),
        tomorrowSchedule: nil
    )
    GomiDayWidgetEntry(
        date: Date(),
        nextSchedule: GarbageSchedule(date: Date().nextDay, garbageType: .plastic),
        tomorrowSchedule: nil
    )
}

