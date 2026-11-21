//
//  AppGroupStorage.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// App Group을 통해 앱과 위젯이 데이터를 공유하는 저장소
class AppGroupStorage {
    
    // ⚠️ 여기를 본인의 App Group ID로 변경하세요!
    static let appGroupID = "group.com.yourname.gomiday"
    
    /// App Group 컨테이너 URL
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
    
    /// 저장 파일 경로
    private static func fileURL(for fileName: String) -> URL? {
        containerURL?.appendingPathComponent(fileName)
    }
    
    // MARK: - 사용자 설정 저장/로드
    
    /// 사용자 설정 파일명
    private static let settingsFileName = "user_settings.json"
    
    /// 사용자 설정 저장
    static func saveSettings(_ settings: UserSettings) {
        guard let url = fileURL(for: settingsFileName) else {
            print("❌ App Group URL을 찾을 수 없습니다.")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: .atomic)
            print("✅ 설정 저장 완료: \(url)")
        } catch {
            print("❌ 설정 저장 실패: \(error)")
        }
    }
    
    /// 사용자 설정 로드
    static func loadSettings() -> UserSettings? {
        guard let url = fileURL(for: settingsFileName) else {
            print("❌ App Group URL을 찾을 수 없습니다.")
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("ℹ️ 저장된 설정 파일이 없습니다.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let settings = try JSONDecoder().decode(UserSettings.self, from: data)
            print("✅ 설정 로드 완료")
            return settings
        } catch {
            print("❌ 설정 로드 실패: \(error)")
            return nil
        }
    }
    
    /// 모든 데이터 삭제 (초기화)
    static func clearAllData() {
        guard let container = containerURL else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: container,
                includingPropertiesForKeys: nil
            )
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            print("✅ 모든 데이터 삭제 완료")
        } catch {
            print("❌ 데이터 삭제 실패: \(error)")
        }
    }
}

/// 사용자 설정 모델
struct UserSettings: Codable {
    var selectedArea: Area?              // 등록된 지역
    var collectionDeadline: TimeOfDay    // 배출 마감 시각 (기본 08:30)
    var notificationEnabled: Bool        // 전날 밤 알림 활성화
    var notificationTime: TimeOfDay      // 알림 시각 (기본 20:00)
    var colorScheme: AppColorScheme      // 다크/라이트 모드
    
    /// 기본값 초기화
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
    
    /// 표시용 문자열 (예: "08:30")
    var displayString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    /// Date로 변환 (오늘 날짜 기준)
    func toDate() -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.tokyo.date(from: components) ?? Date()
    }
}

/// 앱 컬러 스킴
enum AppColorScheme: String, Codable, CaseIterable {
    case system = "システム"
    case light = "ライト"
    case dark = "ダーク"
}
