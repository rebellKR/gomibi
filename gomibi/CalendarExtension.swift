//
//  CalendarExtension.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

extension Calendar {
    
    /// 도쿄 시간대 & 그레고리력 & 주 시작 일요일
    static var tokyo: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        calendar.firstWeekday = 1  // 1 = 일요일
        calendar.locale = Locale(identifier: "ja_JP")
        return calendar
    }
}

extension Date {
    
    /// 도쿄 시간대로 날짜 비교 (년월일만)
    func isSameDay(as other: Date) -> Bool {
        Calendar.tokyo.isDate(self, inSameDayAs: other)
    }
    
    /// 오늘인지 확인 (도쿄 시간대)
    var isToday: Bool {
        Calendar.tokyo.isDateInToday(self)
    }
    
    /// 내일인지 확인 (도쿄 시간대)
    var isTomorrow: Bool {
        Calendar.tokyo.isDateInTomorrow(self)
    }
    
    /// 요일 (1=일요일 ~ 7=토요일)
    var weekday: Int {
        Calendar.tokyo.component(.weekday, from: self)
    }
    
    /// 그 달의 몇 번째 해당 요일인지 (예: 제2 수요일 → 2)
    var weekOfMonth: Int {
        Calendar.tokyo.component(.weekdayOrdinal, from: self)
    }
    
    /// 요일 이름 (일본어, 짧게: 月, 火, 水...)
    var weekdayShortName: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.tokyo
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"  // 짧은 요일명
        return formatter.string(from: self)
    }
    
    /// 월/일 표시 (예: "11/22")
    var monthDayString: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.tokyo
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }
    
    /// 특정 시각으로 Date 생성 (오늘 날짜 기준)
    static func todayAt(hour: Int, minute: Int) -> Date {
        var components = Calendar.tokyo.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.tokyo.date(from: components) ?? Date()
    }
    
    /// 자정 (00:00:00)
    var startOfDay: Date {
        Calendar.tokyo.startOfDay(for: self)
    }
    
    /// 다음 날
    var nextDay: Date {
        Calendar.tokyo.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    /// 이전 날
    var previousDay: Date {
        Calendar.tokyo.date(byAdding: .day, value: -1, to: self) ?? self
    }
}
