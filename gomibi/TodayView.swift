//
//  TodayView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI
import WidgetKit

/// 오늘 화면 (이번 주 일정)
struct TodayView: View {
    
    @Binding var settings: UserSettings
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if let area = settings.selectedArea {
                    // 지역이 등록되어 있으면 일정 표시
                    scheduleContent(for: area)
                } else {
                    // 지역이 없으면 등록 안내
                    emptyStateView
                }
            }
            .navigationTitle("今日のゴミ")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - 일정 컨텐츠
    
    @ViewBuilder
    private func scheduleContent(for area: Area) -> some View {
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: settings.collectionDeadline
        )
        
        ScrollView {
            VStack(spacing: 20) {
                // 오늘/내일 메인 카드
                mainScheduleCard(engine: engine)
                
                // 이번 주 일정
                weekScheduleSection(engine: engine)
            }
            .padding()
        }
    }
    
    // MARK: - 메인 스케줄 카드
    
    @ViewBuilder
    private func mainScheduleCard(engine: ScheduleEngine) -> some View {
        VStack(spacing: 16) {
            // 오늘 일정
            if let next = engine.getNextSchedule() {
                scheduleCard(schedule: next, isMain: true)
            } else {
                noScheduleCard
            }
        }
    }
    
    // MARK: - 일정 카드
    
    @ViewBuilder
    private func scheduleCard(schedule: GarbageSchedule, isMain: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 날짜 표시
            HStack {
                Text(schedule.displayDate())
                    .font(isMain ? .title : .headline)
                    .bold()
                
                Spacer()
                
                Image(systemName: schedule.garbageType.icon)
                    .font(.system(size: isMain ? 40 : 30))
                    .foregroundStyle(schedule.garbageType.color)
            }
            
            // 쓰레기 종류
            Text(schedule.garbageType.rawValue)
                .font(isMain ? .title2 : .title3)
                .bold()
                .foregroundStyle(schedule.garbageType.color)
            
            // 시각 정보
            if schedule.isToday {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("今日 \(settings.collectionDeadline.displayString)まで")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16, antialiased: true)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - 수거 없음 카드
    
    private var noScheduleCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("今日の収集はありません")
                .font(.title3)
                .bold()
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16, antialiased: true)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - 주간 일정 섹션
    
    @ViewBuilder
    private func weekScheduleSection(engine: ScheduleEngine) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週の予定")
                .font(.headline)
                .padding(.horizontal, 4)
            
            let weekSchedules = engine.getThisWeekSchedules()
            
            ForEach(weekSchedules) { daySchedule in
                weekDayRow(daySchedule: daySchedule)
            }
        }
    }
    
    // MARK: - 주간 일정 행
    
    @ViewBuilder
    private func weekDayRow(daySchedule: DaySchedule) -> some View {
        HStack(spacing: 12) {
            // 날짜
            VStack(spacing: 2) {
                Text(daySchedule.date.weekdayShortName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(Calendar.tokyo.component(.day, from: daySchedule.date))")
                    .font(.title3)
                    .bold()
            }
            .frame(width: 40)
            
            // 쓰레기 종류들
            if daySchedule.hasCollection {
                HStack(spacing: 8) {
                    ForEach(daySchedule.schedules) { schedule in
                        HStack(spacing: 6) {
                            Image(systemName: schedule.garbageType.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(schedule.garbageType.color)
                            
                            Text(schedule.garbageType.shortName)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(schedule.garbageType.color.opacity(0.1))
                        .cornerRadius(8, antialiased: true)
                    }
                }
            } else {
                Text("収集なし")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12, antialiased: true)
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("地域を登録してください")
                .font(.title2)
                .bold()
            
            Text("ゴミ収集日を確認するには\n地域を登録する必要があります")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: AreaSearchView(settings: $settings)) {
                Text("地域を登録")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.burnableColor)
                    .cornerRadius(12, antialiased: true)
            }
        }
        .padding(40)
    }
}

#Preview {
    TodayView(settings: .constant(UserSettings(
        selectedArea: Area(
            id: "test",
            prefecture: "東京都",
            city: "世田谷区",
            cityKana: "せたがやく",
            area: "三軒茶屋",
            rules: [
                GarbageScheduleRule(type: .burnable, weekdays: [2, 5]),
                GarbageScheduleRule(type: .plastic, weekdays: [3])
            ],
            exceptions: [],
            source: nil,
            updated: nil
        )
    )))
}
