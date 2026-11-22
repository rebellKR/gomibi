//
//  ContentView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

struct ContentView: View {
    
    // 테스트용 지역 데이터
    private let testArea = Area(
        id: "test-tokyo",
        prefecture: "東京都",
        city: "世田谷区",
        cityKana: "せたがやく",
        area: "三軒茶屋",
        rules: [
            GarbageScheduleRule(type: .burnable, weekdays: [2, 5]),
            GarbageScheduleRule(type: .plastic, weekdays: [3]),
            GarbageScheduleRule(type: .nonBurnable, weekdays: [4], weeks: [1, 3]),
            GarbageScheduleRule(type: .resource, weekdays: [4], weeks: [2, 4])
        ],
        exceptions: [],
        source: nil,
        updated: nil
    )
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            Text("GomiDay")
                .font(.largeTitle)
                .bold()
            
            Text("쓰레기 배출일 알림 앱")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical)
            
            // 2단계 테스트
            VStack(alignment: .leading, spacing: 12) {
                Text("✅ 2단계 완료!")
                    .font(.title2)
                    .bold()
                
                Text("ScheduleEngine 테스트:")
                    .font(.headline)
                
                // 엔진 생성
                let engine = ScheduleEngine(
                    area: testArea,
                    collectionDeadline: TimeOfDay(hour: 8, minute: 30)
                )
                
                // 오늘 일정
                if let next = engine.getNextSchedule() {
                    HStack(spacing: 8) {
                        Image(systemName: next.garbageType.icon)
                            .foregroundStyle(next.garbageType.color)
                        Text("다음: \(next.displayDate()) \(next.garbageType.rawValue)")
                            .font(.body)
                    }
                } else {
                    Text("일정 없음")
                        .foregroundStyle(.secondary)
                }
                
                // 현재 시각
                Text("현재: \(Date(), format: .dateTime.month().day().hour().minute())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16, antialiased: true)
        }
        .padding()
        .background(Color.appBackground)
    }
}

#Preview {
    ContentView()
}
