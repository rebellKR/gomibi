//
//  MonthCalendarView.swift
//  GomiDay
//
//  월 단위 달력: 날짜마다 그날 버리는 쓰레기 색 점 표시, 탭하면 상세
//

import SwiftUI

struct MonthCalendarView: View {
    
    let area: Area
    
    @State private var month: Date = Date().startOfMonth   // 표시 중인 달
    @State private var selected: Date = Date().startOfDay  // 선택한 날짜
    
    private let calendar = Calendar.tokyo
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private var engine: ScheduleEngine {
        ScheduleEngine(area: area, collectionDeadline: TimeOfDay(hour: 0, minute: 0))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            header
            weekdayHeader
            grid
            Divider()
            selectedDayDetail
        }
    }
    
    // MARK: - 월 이동 헤더
    
    private var header: some View {
        HStack {
            Button { moveMonth(-1) } label: {
                Image(systemName: "chevron.left").frame(width: 36, height: 36)
            }
            Spacer()
            Button {
                withAnimation { month = Date().startOfMonth; selected = Date().startOfDay }
            } label: {
                Text(monthTitle).font(.title3.bold()).foregroundStyle(.primary)
            }
            Spacer()
            Button { moveMonth(1) } label: {
                Image(systemName: "chevron.right").frame(width: 36, height: 36)
            }
        }
        .font(.headline)
        .buttonStyle(.borderless)   // Form 안에서도 버튼이 각각 따로 눌리도록
    }
    
    private var monthTitle: String {
        let c = calendar.dateComponents([.year, .month], from: month)
        return "\(c.year ?? 0)年\(c.month ?? 0)月"
    }
    
    // MARK: - 요일 헤더 (日は赤、土は青)
    
    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Weekday.all, id: \.self) { wd in
                Text(Weekday.shortName(wd))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(wd == 1 ? Color.red : wd == 7 ? Color.blue : Color.secondary)
            }
        }
    }
    
    // MARK: - 날짜 그리드
    
    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 52)
                }
            }
        }
        .simultaneousGesture(
            // 좌우 스와이프로 달 이동 (세로 스크롤은 방해하지 않음)
            DragGesture(minimumDistance: 30).onEnded { v in
                guard abs(v.translation.width) > abs(v.translation.height) else { return }
                if v.translation.width < -50 { moveMonth(1) }
                if v.translation.width > 50 { moveMonth(-1) }
            }
        )
    }
    
    /// 이번 달 칸들 (앞쪽 빈칸은 nil)
    private var cells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let leading = calendar.component(.weekday, from: month) - 1
        let days: [Date?] = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
        return Array(repeating: nil, count: leading) + days
    }
    
    private func dayCell(_ date: Date) -> some View {
        let types = engine.daySchedule(for: date).types
        let isSelected = calendar.isDate(date, inSameDayAs: selected)
        let isToday = date.isToday
        let weekday = calendar.component(.weekday, from: date)
        
        return Button {
            withAnimation(.snappy) { selected = date }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.callout.weight(isToday ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color.white :
                                     weekday == 1 ? Color.red : weekday == 7 ? Color.blue : Color.primary)
                    .frame(width: 30, height: 30)
                    .background {
                        if isSelected { Circle().fill(Color.accentColor) }
                        else if isToday { Circle().stroke(Color.accentColor, lineWidth: 1.5) }
                    }
                // 쓰레기 종류 색 점
                HStack(spacing: 3) {
                    ForEach(types) { t in
                        Circle().fill(t.color).frame(width: 6, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.monthDayString) \(types.map(\.rawValue).joined(separator: "、"))")
    }
    
    // MARK: - 선택한 날 상세
    
    private var selectedDayDetail: some View {
        let day = engine.daySchedule(for: selected)
        return VStack(alignment: .leading, spacing: 10) {
            Text(selectedTitle).font(.headline)
            
            if day.hasCollection {
                ForEach(day.schedules) { s in
                    HStack(spacing: 12) {
                        GarbageIcon(type: s.garbageType, size: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.displayName).font(.subheadline.bold())
                            Text(s.garbageType.examples).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Label("収集はありません", systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// "今日・11/23(月)" 또는 "11/30(日)"
    private var selectedTitle: String {
        let base = "\(selected.monthDayString)(\(selected.weekdayShortName))"
        let rel = selected.relativeDisplay()
        return (rel == "今日" || rel == "明日") ? "\(rel)・\(base)" : base
    }
    
    private func moveMonth(_ value: Int) {
        guard let m = calendar.date(byAdding: .month, value: value, to: month) else { return }
        withAnimation(.snappy) {
            month = m
            // 이번 달로 돌아오면 오늘, 아니면 그 달 1일 선택
            selected = calendar.isDate(m, equalTo: Date(), toGranularity: .month) ? Date().startOfDay : m
        }
    }
}

// MARK: - 범례 (이 지역에서 쓰는 종류만)

struct GarbageLegend: View {
    let area: Area
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(uniqueTypes(area)) { GarbageChip(type: $0, label: area.name(for: $0)) }
        }
    }
    
    private func uniqueTypes(_ area: Area) -> [GarbageType] {
        let used = Set(area.rules.map(\.type))
        return GarbageType.allCases.filter { used.contains($0) }
    }
}

// MARK: - 달력 탭

struct CalendarTabView: View {
    @Binding var settings: UserSettings
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let area = settings.selectedArea {
                    VStack(spacing: 16) {
                        MonthCalendarView(area: area).card()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("凡例").font(.headline)
                            GarbageLegend(area: area)
                        }
                        .card()
                    }
                    .padding()
                } else {
                    NoAreaView { showingSearch = true }
                        .padding(.top, 80)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("カレンダー")
            .toolbar {
                if let area = settings.selectedArea {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(area.title).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                AreaSearchView(currentArea: settings.selectedArea) { settings.selectedArea = $0 }
            }
        }
    }
}

// MARK: - 지역 미등록 안내 (여러 화면 공용)

struct NoAreaView: View {
    let action: () -> Void
    var body: some View {
        ContentUnavailableView {
            Label("地域が未登録です", systemImage: "mappin.and.ellipse")
        } description: {
            Text("お住まいの市区町村を登録すると\nゴミの日が表示されます")
        } actions: {
            Button("地域を登録", action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}
