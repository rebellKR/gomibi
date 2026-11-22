//
//  ScheduleEngine.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// 쓰레기 수거 일정을 계산하는 엔진
class ScheduleEngine {
    
    // MARK: - Properties
    
    private let area: Area
    private let collectionDeadline: TimeOfDay
    private let calendar = Calendar.tokyo
    
    // MARK: - Initialization
    
    init(area: Area, collectionDeadline: TimeOfDay) {
        self.area = area
        self.collectionDeadline = collectionDeadline
    }
    
    // MARK: - Public Methods
    
    /// 오늘 수거 일정 가져오기 (마감 시각 고려)
    func getTodaySchedule(at currentTime: Date = Date()) -> [GarbageSchedule] {
        let today = calendar.startOfDay(for: currentTime)
        let deadline = createDeadlineTime(for: today)
        
        // 마감 시각이 지났으면 빈 배열 반환
        if currentTime >= deadline {
            return []
        }
        
        return getSchedules(for: today)
    }
    
    /// 내일 수거 일정 가져오기
    func getTomorrowSchedule(at currentTime: Date = Date()) -> [GarbageSchedule] {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime)!
        let tomorrowStart = calendar.startOfDay(for: tomorrow)
        return getSchedules(for: tomorrowStart)
    }
    
    /// 다음 수거일 가져오기 (마감 시각 고려)
    func getNextSchedule(after currentTime: Date = Date()) -> GarbageSchedule? {
        let today = calendar.startOfDay(for: currentTime)
        let deadline = createDeadlineTime(for: today)
        
        // 마감 전이면 오늘부터, 마감 후면 내일부터 검색
        let searchStart = currentTime < deadline ? today : today.nextDay
        
        // 최대 60일 검색
        for dayOffset in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: searchStart) else {
                continue
            }
            
            let schedules = getSchedules(for: date)
            if let first = schedules.first {
                return first
            }
        }
        
        return nil
    }
    
    /// 특정 날짜의 수거 일정 가져오기
    func getSchedules(for date: Date) -> [GarbageSchedule] {
        let dayStart = calendar.startOfDay(for: date)
        var schedules: [GarbageSchedule] = []
        
        // 각 규칙 확인
        for rule in area.rules {
            if shouldCollect(rule: rule, on: dayStart) {
                // 예외 날짜 확인
                if let exception = findException(for: dayStart, type: rule.type) {
                    if exception.action == .none {
                        // 수거 없음
                        continue
                    } else if exception.action == .reschedule, let newDate = exception.newDate {
                        // 다른 날로 변경됨
                        if calendar.isDate(newDate, inSameDayAs: dayStart) {
                            schedules.append(GarbageSchedule(
                                date: dayStart,
                                garbageType: rule.type,
                                isException: true
                            ))
                        }
                        continue
                    }
                }
                
                // 정상 수거
                schedules.append(GarbageSchedule(
                    date: dayStart,
                    garbageType: rule.type
                ))
            }
        }
        
        return schedules
    }
    
    /// 특정 기간의 일정 가져오기 (주간 뷰용)
    func getSchedules(from startDate: Date, to endDate: Date) -> [DaySchedule] {
        var daySchedules: [DaySchedule] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        while currentDate <= end {
            let schedules = getSchedules(for: currentDate)
            daySchedules.append(DaySchedule(
                date: currentDate,
                schedules: schedules
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return daySchedules
    }
    
    /// 이번 주 일정 가져오기 (일요일~토요일)
    func getThisWeekSchedules(relativeTo date: Date = Date()) -> [DaySchedule] {
        // 이번 주 일요일 찾기
        let weekday = calendar.component(.weekday, from: date)
        let daysFromSunday = weekday - 1  // 일요일=1이므로
        guard let sunday = calendar.date(byAdding: .day, value: -daysFromSunday, to: date) else {
            return []
        }
        
        // 이번 주 토요일
        guard let saturday = calendar.date(byAdding: .day, value: 6, to: sunday) else {
            return []
        }
        
        return getSchedules(from: sunday, to: saturday)
    }
    
    // MARK: - Private Methods
    
    /// 특정 날짜에 해당 규칙의 수거가 있는지 확인
    private func shouldCollect(rule: GarbageScheduleRule, on date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        
        // 요일이 맞는지 확인
        guard rule.weekdays.contains(weekday) else {
            return false
        }
        
        // 주차 제한이 있으면 확인 (예: 제2·제4 수요일)
        if let weeks = rule.weeks {
            let weekOfMonth = calendar.component(.weekdayOrdinal, from: date)
            guard weeks.contains(weekOfMonth) else {
                return false
            }
        }
        
        // 격주 확인
        if let biweeklyStart = rule.biweeklyStartDate {
            let daysBetween = calendar.dateComponents([.day], from: biweeklyStart, to: date).day ?? 0
            let weeksBetween = daysBetween / 7
            
            // 짝수 주 또는 홀수 주인지 확인
            if weeksBetween % 2 != 0 {
                return false
            }
        }
        
        return true
    }
    
    /// 예외 날짜 찾기
    private func findException(for date: Date, type: GarbageType) -> ScheduleException? {
        return area.exceptions.first { exception in
            calendar.isDate(exception.originalDate, inSameDayAs: date)
        }
    }
    
    /// 특정 날짜의 마감 시각 생성
    private func createDeadlineTime(for date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = collectionDeadline.hour
        components.minute = collectionDeadline.minute
        return calendar.date(from: components) ?? date
    }
}
