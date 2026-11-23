//
//  gomiDayWidgetBundle.swift
//  gomiDayWidget
//
//  잠금화면(원형·직사각형·한 줄) + 홈화면(소·중) 위젯
//

import WidgetKit
import SwiftUI

@main
struct gomiDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        GomiDayWidget()
    }
}

// MARK: - 위젯 정의

struct GomiDayWidget: Widget {
    let kind = "GomiDayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GomiProvider()) { entry in
            GomiWidgetView(entry: entry)
        }
        .configurationDisplayName("ゴミの日")
        .description("次のゴミの日をひと目で確認できます")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium])
    }
}

// MARK: - 데이터 (엔트리)

struct GomiEntry: TimelineEntry {
    let date: Date
    let areaName: String?            // nil = 지역 미등록
    let next: DaySchedule?           // 다음 수거일
    let following: [DaySchedule]     // 그 다음 수거일들
    let deadline: TimeOfDay
    
    /// "今日" / "明日" / "3日後"
    var nextLabel: String {
        guard let next else { return "" }
        switch next.date.daysFromToday(date) {
        case 0: return "今日"
        case 1: return "明日"
        case let n: return "\(n)日後"
        }
    }
    
    static let sample = GomiEntry(
        date: Date(), areaName: "世田谷区",
        next: DaySchedule(date: Date().nextDay, schedules: [GarbageSchedule(date: Date().nextDay, garbageType: .burnable)]),
        following: [
            DaySchedule(date: Date().nextDay.nextDay, schedules: [GarbageSchedule(date: Date(), garbageType: .plastic)]),
            DaySchedule(date: Date().nextDay.nextDay.nextDay, schedules: [GarbageSchedule(date: Date(), garbageType: .resource)])
        ],
        deadline: TimeOfDay(hour: 8, minute: 30))
}

// MARK: - 타임라인

struct GomiProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> GomiEntry { .sample }
    
    func getSnapshot(in context: Context, completion: @escaping (GomiEntry) -> Void) {
        let entry = makeEntry(at: Date())
        // 위젯 갤러리에서 지역이 없으면 샘플을 보여줌
        completion(context.isPreview && entry.areaName == nil ? .sample : entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GomiEntry>) -> Void) {
        // 표시가 바뀌는 순간들(자정·마감 시각)마다 엔트리를 미리 만들어 둠 → 앱을 안 열어도 자동 전환
        let now = Date()
        var dates: [Date] = [now]
        let deadline = (AppGroupStorage.loadSettings() ?? UserSettings()).collectionDeadline
        let cal = Calendar.tokyo
        for offset in 0..<3 {
            guard let day = cal.date(byAdding: .day, value: offset, to: now.startOfDay) else { continue }
            var c = cal.dateComponents([.year, .month, .day], from: day)
            c.hour = deadline.hour
            c.minute = deadline.minute
            if let d = cal.date(from: c), d > now { dates.append(d) }   // 마감 시각
            if day > now { dates.append(day) }                           // 자정
        }
        let entries = dates.sorted().map { makeEntry(at: $0) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
    
    private func makeEntry(at date: Date) -> GomiEntry {
        let settings = AppGroupStorage.loadSettings() ?? UserSettings()
        guard let area = settings.selectedArea else {
            return GomiEntry(date: date, areaName: nil, next: nil, following: [], deadline: settings.collectionDeadline)
        }
        let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
        let days = engine.upcomingCollectionDays(after: date, limit: 4)
        return GomiEntry(date: date,
                         areaName: area.area ?? area.title,
                         next: days.first,
                         following: Array(days.dropFirst()),
                         deadline: settings.collectionDeadline)
    }
}

// MARK: - 뷰 분기

struct GomiWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: GomiEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(entry: entry)
                .containerBackground(for: .widget) { AccessoryWidgetBackground() }
        case .accessoryRectangular:
            RectangularView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        case .accessoryInline:
            InlineView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        case .systemMedium:
            MediumView(entry: entry)
                .containerBackground(for: .widget) { background }
        default:
            SmallView(entry: entry)
                .containerBackground(for: .widget) { background }
        }
    }
    
    /// 홈 위젯 배경: 다음 쓰레기 종류 색
    private var background: some View {
        Rectangle().fill((entry.next?.types.first?.color ?? Color.gray).gradient)
    }
}

// MARK: - 잠금화면: 원형

private struct CircularView: View {
    let entry: GomiEntry
    var body: some View {
        if let next = entry.next, let type = next.types.first {
            VStack(spacing: 1) {
                Image(systemName: type.icon).font(.system(size: 18, weight: .semibold))
                Text(entry.nextLabel).font(.system(size: 11, weight: .bold))
                    .minimumScaleFactor(0.7)
            }
            .widgetAccentable()
        } else {
            Image(systemName: entry.areaName == nil ? "mappin.slash" : "trash.slash")
                .font(.system(size: 20))
        }
    }
}

// MARK: - 잠금화면: 직사각형

private struct RectangularView: View {
    let entry: GomiEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let next = entry.next {
                HStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                    Text("\(entry.nextLabel) \(next.date.monthDayString)(\(next.date.weekdayShortName))")
                }
                .font(.system(size: 13, weight: .semibold))
                .widgetAccentable()
                
                Text(next.typesLongText)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                if let after = entry.following.first {
                    Text("次: \(after.date.relativeDisplay(from: entry.date)) \(after.typesText)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Text(entry.areaName == nil ? "アプリで地域を登録" : "収集予定なし")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 잠금화면: 한 줄 (시계 위)

private struct InlineView: View {
    let entry: GomiEntry
    var body: some View {
        if let next = entry.next {
            Label("\(entry.nextLabel) \(next.typesText)", systemImage: "trash")
        } else {
            Label(entry.areaName == nil ? "地域未登録" : "収集なし", systemImage: "trash.slash")
        }
    }
}

// MARK: - 홈화면: 소

private struct SmallView: View {
    let entry: GomiEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let next = entry.next {
                HStack {
                    Text(entry.nextLabel).font(.system(size: 30, weight: .heavy, design: .rounded))
                    Spacer()
                    if let type = next.types.first {
                        Image(systemName: type.icon).font(.title2)
                    }
                }
                Text("\(next.date.monthDayString)(\(next.date.weekdayShortName))")
                    .font(.subheadline.weight(.semibold)).opacity(0.85)
                Spacer(minLength: 0)
                ForEach(next.schedules) { s in
                    Text(s.displayName).font(.headline.bold()).lineLimit(1).minimumScaleFactor(0.7)
                }
                Text("\(entry.deadline.displayString)まで").font(.caption2).opacity(0.85)
            } else {
                Image(systemName: "mappin.and.ellipse").font(.title)
                Spacer()
                Text(entry.areaName == nil ? "アプリで地域を\n登録してください" : "収集予定なし")
                    .font(.subheadline.bold())
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - 홈화면: 중

private struct MediumView: View {
    let entry: GomiEntry
    var body: some View {
        HStack(spacing: 16) {
            SmallView(entry: entry)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.areaName ?? "").font(.caption.weight(.semibold)).opacity(0.85)
                ForEach(entry.following.prefix(3)) { day in
                    HStack(spacing: 6) {
                        Text(day.date.relativeDisplay(from: entry.date))
                            .font(.caption.weight(.bold))
                            .frame(width: 62, alignment: .leading)
                        Text(day.typesText).font(.caption).lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

// MARK: - 미리보기

#Preview("Rectangular", as: .accessoryRectangular) { GomiDayWidget() } timeline: { GomiEntry.sample }
#Preview("Small", as: .systemSmall) { GomiDayWidget() } timeline: { GomiEntry.sample }
#Preview("Medium", as: .systemMedium) { GomiDayWidget() } timeline: { GomiEntry.sample }
