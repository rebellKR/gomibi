//
//  NotificationManager.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/23.
//

import Foundation
import UserNotifications
import Combine

/// 알림 관리자
class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorization()
    }
    
    // MARK: - 권한 요청
    
    /// 알림 권한 요청
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                print("✅ 알림 권한 허용됨")
            } else {
                print("❌ 알림 권한 거부됨")
            }
            
            return granted
        } catch {
            print("❌ 알림 권한 요청 실패: \(error)")
            return false
        }
    }
    
    /// 현재 권한 상태 확인
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - 알림 스케줄링
    
    /// 전날 밤 알림 설정
    func scheduleDailyNotifications(settings: UserSettings) async {
        // 기존 알림 모두 삭제
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard settings.notificationEnabled,
              let area = settings.selectedArea else {
            print("ℹ️ 알림 비활성화 또는 지역 미등록")
            return
        }
        
        // 권한 확인
        guard isAuthorized else {
            print("❌ 알림 권한 없음")
            return
        }
        
        // 엔진 생성
        let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
        
        // 앞으로 7일간의 일정 확인
        let today = Date()
        for dayOffset in 1...7 {
            guard let date = Calendar.tokyo.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            
            let schedules = engine.getSchedules(for: date)
            
            if !schedules.isEmpty {
                // 전날 밤 알림 생성
                scheduleNotification(
                    for: schedules,
                    on: date,
                    notificationTime: settings.notificationTime
                )
            }
        }
        
        print("✅ 알림 스케줄 완료 (최대 7일)")
    }
    
    /// 특정 날짜의 알림 생성
    private func scheduleNotification(
        for schedules: [GarbageSchedule],
        on date: Date,
        notificationTime: TimeOfDay
    ) {
        let calendar = Calendar.tokyo
        
        // 전날 계산
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: date) else {
            return
        }
        
        // 알림 시각 설정
        var components = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        components.hour = notificationTime.hour
        components.minute = notificationTime.minute
        
        // 알림 내용
        let types = schedules.map { $0.garbageType.rawValue }.joined(separator: "、")
        let weekday = date.weekdayShortName
        
        let content = UNMutableNotificationContent()
        content.title = "明日はゴミの日です"
        content.body = "明日(\(weekday))は\(types)の収集日です"
        content.sound = .default
        content.badge = 1
        
        // 트리거 생성
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 요청 생성 (고유 ID)
        let identifier = "gomi-\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // 알림 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error)")
            } else {
                print("✅ 알림 등록: \(weekday) \(types)")
            }
        }
    }
    
    // MARK: - 알림 취소
    
    /// 모든 알림 취소
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ 모든 알림 취소됨")
    }
    
    /// 예정된 알림 개수 확인
    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}
