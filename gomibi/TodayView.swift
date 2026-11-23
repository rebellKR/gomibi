//
//  TodayView.swift
//  GomiDay
//
//  홈 화면: 다음 수거일을 크게, 그 아래 7일 일정
//

import SwiftUI

struct TodayView: View {
    
    @Binding var settings: UserSettings
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            // 1분마다 다시 그려서 "마감 시각 지나면 다음 날로" 자동 반영
            TimelineView(.everyMinute) { context in
                ScrollView {
                    if let area = settings.selectedArea {
                        content(area: area, now: context.date)
                            .padding()
                    } else {
                        NoAreaView { showingSearch = true }
                            .padding(.top, 80)
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("ゴミの日")
            .sheet(isPresented: $showingSearch) {
                AreaSearchView(currentArea: settings.selectedArea) { settings.selectedArea = $0 }
            }
        }
    }
    
    // MARK: - 본문
    
    @ViewBuilder
    private func content(area: Area, now: Date) -> some View {
        let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
        
        VStack(alignment: .leading, spacing: 20) {
            // 지역 버튼 (탭하면 변경)
            Button { showingSearch = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                    Text(area.title)
                    Image(systemName: "chevron.down").font(.caption2)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            }
            
            if let next = engine.nextCollectionDay(after: now) {
                heroCard(next, now: now)
            } else {
                Text("収集日が設定されていません").card()
            }
            
            // 앞으로 7일
            VStack(alignment: .leading, spacing: 0) {
                Text("1週間の予定").font(.headline).padding(.bottom, 8)
                ForEach(engine.nextSevenDays(from: now)) { day in
                    dayRow(day, now: now)
                    if day.date != engine.nextSevenDays(from: now).last?.date { Divider() }
                }
            }
            .card()
        }
    }
    
    // MARK: - 메인 카드
    
    private func heroCard(_ day: DaySchedule, now: Date) -> some View {
        let daysLeft = day.date.daysFromToday(now)
        let mainColor = day.types.first?.color ?? .accentColor
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(daysLeft == 0 ? "今日" : daysLeft == 1 ? "明日" : "\(daysLeft)日後")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                Spacer()
                Text("\(day.date.monthDayString)(\(day.date.weekdayShortName))")
                    .font(.title3.weight(.semibold))
                    .opacity(0.85)
            }
            
            ForEach(day.schedules) { s in
                HStack(spacing: 12) {
                    Image(systemName: s.garbageType.icon)
                        .font(.title2.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.25), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.displayName).font(.title2.bold())
                        Text(s.garbageType.examples).font(.caption).opacity(0.85)
                    }
                }
            }
            
            Label(daysLeft == 0 ? "今日 \(settings.collectionDeadline.displayString) までに出しましょう"
                                : "当日 \(settings.collectionDeadline.displayString) までに出しましょう",
                  systemImage: "clock")
                .font(.footnote.weight(.medium))
                .opacity(0.9)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(mainColor.gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: mainColor.opacity(0.3), radius: 12, y: 6)
    }
    
    // MARK: - 하루 행
    
    private func dayRow(_ day: DaySchedule, now: Date) -> some View {
        let isToday = Calendar.tokyo.isDate(day.date, inSameDayAs: now)
        let weekday = day.date.weekday
        return HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(day.date.weekdayShortName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(weekday == 1 ? Color.red : weekday == 7 ? Color.blue : Color.secondary)
                Text("\(Calendar.tokyo.component(.day, from: day.date))")
                    .font(.title3.weight(isToday ? .heavy : .semibold))
            }
            .frame(width: 36)
            
            if day.hasCollection {
                FlowLayout(spacing: 6) {
                    ForEach(day.schedules) { GarbageChip(type: $0.garbageType, label: $0.displayName) }
                }
            } else {
                Text("収集なし").font(.subheadline).foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
            if isToday {
                Text("今日").font(.caption2.bold()).foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 10)
    }
}
