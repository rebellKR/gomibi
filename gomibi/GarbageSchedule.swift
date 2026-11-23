//
//  GarbageSchedule.swift
//  GomiDay
//

import Foundation

/// 특정 날짜의 쓰레기 1종류
struct GarbageSchedule: Identifiable, Equatable {
    var id: String { "\(date.timeIntervalSince1970)-\(garbageType.rawValue)" }
    let date: Date
    let garbageType: GarbageType
    var isException: Bool = false
    var name: String? = nil        // 지역별 이름 (없으면 기본 이름)
    var shortName: String? = nil
    
    var displayName: String { name ?? garbageType.rawValue }
    var displayShortName: String { shortName ?? garbageType.shortName }
    
    var isToday: Bool { date.isToday }
    
    /// "今日" / "明日" / "11/24(月)"
    func displayDate(relativeTo reference: Date = Date()) -> String {
        date.relativeDisplay(from: reference)
    }
}

/// 하루치 일정 (여러 종류 가능)
struct DaySchedule: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let schedules: [GarbageSchedule]
    
    var hasCollection: Bool { !schedules.isEmpty }
    var types: [GarbageType] { schedules.map(\.garbageType) }
    
    /// "可燃・資源"
    var typesText: String { schedules.map(\.displayShortName).joined(separator: "・") }
    /// "可燃ごみ・資源ごみ"
    var typesLongText: String { schedules.map(\.displayName).joined(separator: "・") }
}
