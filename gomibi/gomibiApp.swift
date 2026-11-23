//
//  gomibiApp.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

@main
struct gomibiApp: App {
    
    // 사용자 설정 State
    @State private var settings: UserSettings = AppGroupStorage.loadSettings() ?? UserSettings()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(settings: $settings)
                .preferredColorScheme(colorScheme)
                .onAppear {
                    // 앱 시작 시 초기 설정 저장
                    if AppGroupStorage.loadSettings() == nil {
                        AppGroupStorage.saveSettings(settings)
                    }
                }
        }
    }
    
    /// 컬러 스킴 적용
    private var colorScheme: ColorScheme? {
        switch settings.colorScheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
