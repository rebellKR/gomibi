//
//  MainTabView.swift
//  GomiDay
//

import SwiftUI

struct MainTabView: View {
    @Binding var settings: UserSettings
    
    var body: some View {
        TabView {
            Tab("今日", systemImage: "trash") {
                TodayView(settings: $settings)
            }
            Tab("カレンダー", systemImage: "calendar") {
                CalendarTabView(settings: $settings)
            }
            Tab("設定", systemImage: "gearshape") {
                SettingsView(settings: $settings)
            }
        }
    }
}

#Preview {
    MainTabView(settings: .constant(UserSettings()))
}
