//
//  GarbageScheduleRule.swift
//  GomiDay
//

import Foundation

/// 쓰레기 배출 규칙 (예: 매주 화·금 가연 / 제1·3 목 불연)
struct GarbageScheduleRule: Codable, Identifiable, Equatable {
    var id: UUID
    var type: GarbageType           // 쓰레기 종류
    var weekdays: [Int]             // 요일 (1=일 ~ 7=토)
    var weeks: [Int]?               // 제n주 (nil이면 매주)
    var biweeklyStartDate: Date?    // 격주 기준일 (nil이면 격주 아님)
    
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
    
    /// 사람이 읽는 설명 (예: "毎週 火・金", "第1・第3 木曜")
    var scheduleText: String {
        let days = weekdays.sorted().map { Weekday.shortName($0) }.joined(separator: "・")
        if let weeks, !weeks.isEmpty {
            let w = weeks.sorted().map { "第\($0)" }.joined(separator: "・")
            return "\(w) \(days)曜"
        }
        if biweeklyStartDate != nil {
            return "隔週 \(days)曜"
        }
        return "毎週 \(days)曜"
    }
}

/// 요일 이름 도우미 (1=日 ~ 7=土)
enum Weekday {
    static let all = Array(1...7)
    static func shortName(_ weekday: Int) -> String {
        let names = ["日", "月", "火", "水", "木", "金", "土"]
        return names[(weekday - 1 + 7) % 7]
    }
}

/// 예외 날짜 (연말연시 등)
struct ScheduleException: Codable, Identifiable, Equatable {
    let id: UUID
    let originalDate: Date
    let action: ExceptionAction
    let newDate: Date?
    
    init(id: UUID = UUID(), originalDate: Date, action: ExceptionAction, newDate: Date? = nil) {
        self.id = id
        self.originalDate = originalDate
        self.action = action
        self.newDate = newDate
    }
}

enum ExceptionAction: String, Codable {
    case none        // 수거 없음
    case reschedule  // 다른 날로 변경
}
