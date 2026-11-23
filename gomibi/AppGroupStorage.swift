//
//  AppGroupStorage.swift
//  GomiDay
//
//  앱과 위젯이 같은 설정을 읽도록 App Group의 UserDefaults에 저장합니다.
//  (App Group이 없으면 앱 전용 저장소로 자동 대체 → 앱은 항상 동작)
//

import Foundation

enum AppGroupStorage {
    
    /// App Group ID (gomibi.entitlements / gomiDayWidget.entitlements 와 같아야 함)
    static let appGroupID = "group.com.codehy.gomibi"
    
    private static let settingsKey = "user_settings"
    
    /// 공유 저장소 (App Group 사용 불가 시 standard)
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
    
    /// App Group이 실제로 연결되어 있는지 (위젯 공유 가능 여부)
    static var isAppGroupAvailable: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    }
    
    /// 설정 저장
    static func saveSettings(_ settings: UserSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            print("❌ 설정 저장 실패: \(error)")
        }
    }
    
    /// 설정 불러오기
    static func loadSettings() -> UserSettings? {
        guard let data = defaults.data(forKey: settingsKey) else { return nil }
        do {
            return try JSONDecoder().decode(UserSettings.self, from: data)
        } catch {
            print("❌ 설정 로드 실패: \(error)")
            return nil
        }
    }
    
    /// 모든 데이터 삭제
    static func clearAllData() {
        defaults.removeObject(forKey: settingsKey)
    }
}

/// 사용자 설정
struct UserSettings: Codable, Equatable {
    var selectedArea: Area?              // 등록된 지역
    var collectionDeadline: TimeOfDay    // 배출 마감 시각 (기본 08:30)
    var notificationEnabled: Bool        // 전날 밤 알림
    var notificationTime: TimeOfDay      // 알림 시각 (기본 20:00)
    var colorScheme: AppColorScheme      // 외관 모드
    
    init(
        selectedArea: Area? = nil,
        collectionDeadline: TimeOfDay = TimeOfDay(hour: 8, minute: 30),
        notificationEnabled: Bool = false,
        notificationTime: TimeOfDay = TimeOfDay(hour: 20, minute: 0),
        colorScheme: AppColorScheme = .system
    ) {
        self.selectedArea = selectedArea
        self.collectionDeadline = collectionDeadline
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.colorScheme = colorScheme
    }
}

/// 시각 (시:분)
struct TimeOfDay: Codable, Equatable {
    let hour: Int
    let minute: Int
    
    /// "08:30" 형태
    var displayString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    /// DatePicker용: 오늘 날짜 + 이 시각
    var asDate: Date {
        Date.todayAt(hour: hour, minute: minute)
    }
    
    /// DatePicker에서 고른 Date → TimeOfDay
    init(date: Date) {
        let c = Calendar.tokyo.dateComponents([.hour, .minute], from: date)
        self.hour = c.hour ?? 0
        self.minute = c.minute ?? 0
    }
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

/// 외관 모드
enum AppColorScheme: String, Codable, CaseIterable {
    case system = "システム"
    case light = "ライト"
    case dark = "ダーク"
}
