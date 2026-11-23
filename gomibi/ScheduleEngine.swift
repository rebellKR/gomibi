//
//  ScheduleEngine.swift
//  GomiDay
//
//  지역 규칙을 보고 "어느 날 무슨 쓰레기"인지 계산하는 엔진
//

import Foundation

struct ScheduleEngine {
    
    let area: Area
    let collectionDeadline: TimeOfDay
    private let calendar = Calendar.tokyo
    
    init(area: Area, collectionDeadline: TimeOfDay) {
        self.area = area
        self.collectionDeadline = collectionDeadline
    }
    
    // MARK: - 하루 단위
    
    /// 특정 날짜의 수거 일정 (종류 순서대로 정렬)
    func getSchedules(for date: Date) -> [GarbageSchedule] {
        let day = calendar.startOfDay(for: date)
        var result: [GarbageSchedule] = []
        
        for rule in area.rules where shouldCollect(rule: rule, on: day) {
            // 예외 날짜(연말연시 등) 처리
            if let exception = area.exceptions.first(where: { calendar.isDate($0.originalDate, inSameDayAs: day) }) {
                if exception.action == .none { continue }
            }
            result.append(makeSchedule(day, rule.type))
        }
        
        // 다른 날에서 이 날로 옮겨온 예외 수거
        for exception in area.exceptions where exception.action == .reschedule {
            if let newDate = exception.newDate, calendar.isDate(newDate, inSameDayAs: day) {
                for rule in area.rules where shouldCollect(rule: rule, on: exception.originalDate) {
                    var s = makeSchedule(day, rule.type)
                    s.isException = true
                    result.append(s)
                }
            }
        }
        
        // 같은 종류 중복 제거 + 정렬
        var seen = Set<GarbageType>()
        return result
            .filter { seen.insert($0.garbageType).inserted }
            .sorted { GarbageType.allCases.firstIndex(of: $0.garbageType)! < GarbageType.allCases.firstIndex(of: $1.garbageType)! }
    }
    
    private func makeSchedule(_ day: Date, _ type: GarbageType) -> GarbageSchedule {
        GarbageSchedule(date: day, garbageType: type,
                        name: area.name(for: type), shortName: area.shortName(for: type))
    }
    
    /// 특정 날짜를 DaySchedule로
    func daySchedule(for date: Date) -> DaySchedule {
        DaySchedule(date: calendar.startOfDay(for: date), schedules: getSchedules(for: date))
    }
    
    // MARK: - 다음 수거일
    
    /// 다음 수거일 (마감 시각이 지났으면 오늘은 건너뜀). 그날의 모든 종류를 반환
    func nextCollectionDay(after now: Date = Date()) -> DaySchedule? {
        let today = calendar.startOfDay(for: now)
        let start = now < deadline(on: today) ? today : today.nextDay
        for offset in 0..<62 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            let day = daySchedule(for: date)
            if day.hasCollection { return day }
        }
        return nil
    }
    
    /// 다음 수거일 이후의 수거일들 (위젯·오늘 화면의 "그 다음" 표시용)
    func upcomingCollectionDays(after now: Date = Date(), limit: Int) -> [DaySchedule] {
        var days: [DaySchedule] = []
        var cursor = now
        while days.count < limit, let next = nextCollectionDay(after: cursor) {
            days.append(next)
            // 다음 날 0시부터 다시 찾기
            cursor = next.date.nextDay
        }
        return days
    }
    
    /// 이전 버전 호환용: 다음 수거 1건
    func getNextSchedule(after now: Date = Date()) -> GarbageSchedule? {
        nextCollectionDay(after: now)?.schedules.first
    }
    
    // MARK: - 기간 단위
    
    /// 기간 내 매일의 일정
    func getSchedules(from startDate: Date, to endDate: Date) -> [DaySchedule] {
        var days: [DaySchedule] = []
        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        while current <= end {
            days.append(daySchedule(for: current))
            current = current.nextDay
        }
        return days
    }
    
    /// 오늘부터 7일간
    func nextSevenDays(from date: Date = Date()) -> [DaySchedule] {
        getSchedules(from: date, to: calendar.date(byAdding: .day, value: 6, to: date) ?? date)
    }
    
    // MARK: - 규칙 판정
    
    private func shouldCollect(rule: GarbageScheduleRule, on date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        guard rule.weekdays.contains(weekday) else { return false }
        
        // 제n주 (예: 제2·제4 수요일) → 그 달의 n번째 해당 요일
        if let weeks = rule.weeks, !weeks.isEmpty {
            let ordinal = calendar.component(.weekdayOrdinal, from: date)
            guard weeks.contains(ordinal) else { return false }
        }
        
        // 격주: 기준일로부터 짝수 주차만 수거 (기준일 이전 날짜도 정확히 계산)
        if let start = rule.biweeklyStartDate {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: date).day ?? 0
            let weeks = Int((Double(days) / 7.0).rounded(.down))
            if weeks % 2 != 0 { return false }
        }
        return true
    }
    
    /// 그 날의 배출 마감 시각
    private func deadline(on day: Date) -> Date {
        var c = calendar.dateComponents([.year, .month, .day], from: day)
        c.hour = collectionDeadline.hour
        c.minute = collectionDeadline.minute
        return calendar.date(from: c) ?? day
    }
}
