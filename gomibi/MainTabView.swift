//
//  MainTabView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

/// 메인 탭 뷰
struct MainTabView: View {
    
    @Binding var settings: UserSettings
    
    var body: some View {
        TabView {
            // 오늘 탭
            TodayView(settings: $settings)
                .tabItem {
                    Label("オ늘", systemImage: "calendar")
                }
            
            // 지역 탭
            AreaSearchView(settings: $settings)
                .tabItem {
                    Label("地域", systemImage: "map")
                }
            
            // 설정 탭
            SettingsView(settings: $settings)
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .tint(Color.burnableColor)  // 탭 선택 색상
    }
}

#Preview {
    MainTabView(settings: .constant(UserSettings()))
}
