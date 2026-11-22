//
//  GarbageSchedule.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// 특정 날짜의 쓰레기 수거 정보
struct GarbageSchedule: Identifiable, Equatable {
    let id: UUID
    let date: Date                 // 수거 날짜
    let garbageType: GarbageType   // 쓰레기 종류
    let isException: Bool          // 예외 날짜인가?
    
    init(
        id: UUID = UUID(),
        date: Date,
        garbageType: GarbageType,
        isException: Bool = false
    ) {
        self.id = id
        self.date = date
        self.garbageType = garbageType
        self.isException = isException
    }
    
    /// 오늘인지 확인
    var isToday: Bool {
        date.isToday
    }
    
    /// 내일인지 확인
    var isTomorrow: Bool {
        date.isTomorrow
    }
    
    /// 표시용 날짜 문자열 (예: "今日", "明日", "11/24 月")
    func displayDate(relativeTo referenceDate: Date = Date()) -> String {
        if Calendar.tokyo.isDate(date, inSameDayAs: referenceDate) {
            return "今日"
        } else if Calendar.tokyo.isDateInTomorrow(date) {
            return "明日"
        } else {
            // 월/일 + 요일
            return "\(date.monthDayString) \(date.weekdayShortName)"
        }
    }
}

/// 여러 종류의 쓰레기를 한 날짜에 모은 것
struct DaySchedule: Identifiable {
    let id: UUID
    let date: Date
    let schedules: [GarbageSchedule]  // 그 날 수거되는 쓰레기들
    
    init(id: UUID = UUID(), date: Date, schedules: [GarbageSchedule]) {
        self.id = id
        self.date = date
        self.schedules = schedules
    }
    
    /// 수거가 있는가?
    var hasCollection: Bool {
        !schedules.isEmpty
    }
    
    /// 종류별 간단 표시 (예: "可燃·資源")
    var typesText: String {
        schedules.map { $0.garbageType.shortName }.joined(separator: "·")
    }
}
