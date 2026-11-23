//
//  NotificationManager.swift
//  GomiDay
//
//  수거일 전날 밤 알림. 앱을 열 때마다 앞으로 30일치를 다시 예약합니다.
//

import Foundation
import UserNotifications

enum NotificationManager {
    
    private static var center: UNUserNotificationCenter { .current() }
    
    /// 권한 요청 (처음 한 번 팝업)
    static func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
    
    /// 현재 권한이 있는지
    static func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }
    
    /// 설정에 맞춰 알림 다시 예약 (기존 예약은 모두 지움)
    static func reschedule(settings: UserSettings) async {
        center.removeAllPendingNotificationRequests()
        
        guard settings.notificationEnabled,
              let area = settings.selectedArea,
              await isAuthorized() else { return }
        
        let engine = ScheduleEngine(area: area, collectionDeadline: settings.collectionDeadline)
        let cal = Calendar.tokyo
        let now = Date()
        
        // iOS는 예약 알림 최대 64개 → 30일이면 충분
        for offset in 1...30 {
            guard let date = cal.date(byAdding: .day, value: offset, to: now) else { continue }
            let day = engine.daySchedule(for: date)
            guard day.hasCollection, let dayBefore = cal.date(byAdding: .day, value: -1, to: day.date) else { continue }
            
            // 전날 밤 알림 시각
            var c = cal.dateComponents([.year, .month, .day], from: dayBefore)
            c.hour = settings.notificationTime.hour
            c.minute = settings.notificationTime.minute
            c.timeZone = cal.timeZone
            guard let fireDate = cal.date(from: c), fireDate > now else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "明日は\(day.typesLongText)の日"
            content.body = "\(day.date.monthDayString)(\(day.date.weekdayShortName)) \(settings.collectionDeadline.displayString)までに出しましょう"
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: c, repeats: false)
            let request = UNNotificationRequest(identifier: "gomi-\(Int(day.date.timeIntervalSince1970))",
                                                content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
    
    /// 예약된 알림 개수
    static func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }
    
    /// 모두 취소
    static func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
