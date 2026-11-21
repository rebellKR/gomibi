//
//  GarbageScheduleRule.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// 쓰레기 배출 규칙
struct GarbageScheduleRule: Codable, Identifiable {
    let id: UUID
    let type: GarbageType           // 쓰레기 종류
    let weekdays: [Int]              // 요일 (1=일요일 ~ 7=토요일)
    let weeks: [Int]?                // 주차 (nil이면 매주, [2,4]면 제2·제4주)
    let biweeklyStartDate: Date?     // 격주 기준일 (nil이면 격주 아님)
    
    init(
        id: UUID = UUID(),
        type: GarbageType,
        weekdays: [Int],
        weeks: [Int]? = nil,
        biweeklyStartDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.weekdays = weekdays
        self.weeks = weeks
        self.biweeklyStartDate = biweeklyStartDate
    }
}

/// 예외 날짜 (연말연시, 공휴일 등)
struct ScheduleException: Codable, Identifiable {
    let id: UUID
    let originalDate: Date   // 원래 수거일
    let action: ExceptionAction
    let newDate: Date?       // 대체일 (action이 .reschedule일 때)
    
    init(
        id: UUID = UUID(),
        originalDate: Date,
        action: ExceptionAction,
        newDate: Date? = nil
    ) {
        self.id = id
        self.originalDate = originalDate
        self.action = action
        self.newDate = newDate
    }
}

/// 예외 처리 방법
enum ExceptionAction: String, Codable {
    case none        // 수거 없음
    case reschedule  // 다른 날로 변경
}
