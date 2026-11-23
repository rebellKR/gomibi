//
//  gomibiApp.swift
//  GomiDay
//

import SwiftUI
import WidgetKit

@main
struct gomibiApp: App {
    
    @State private var settings: UserSettings = AppGroupStorage.loadSettings() ?? UserSettings()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showReRegisterAlert = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView(settings: $settings)
                .preferredColorScheme(colorScheme)
                // 설정이 바뀌면 → 저장 + 위젯 갱신 + 알림 재예약 (한 곳에서 처리)
                .onChange(of: settings) { _, newValue in
                    AppGroupStorage.saveSettings(newValue)
                    WidgetCenter.shared.reloadAllTimelines()
                    Task { await NotificationManager.reschedule(settings: newValue) }
                }
                // 저장된 지역을 최신 데이터로 교체 (앱 실행 시 1번)
                .task { refreshAreaFromLatestData() }
                .alert("収集日データを更新しました", isPresented: $showReRegisterAlert) {
                    Button("OK") {}
                } message: {
                    Text("より正確な地区別データになりました。お住まいの地域をもう一度登録してください。")
                }
                // 앱을 열 때마다 알림을 앞으로 30일치로 채워 둠
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await NotificationManager.reschedule(settings: settings) }
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }
    
    /// 저장된 지역은 "등록한 순간의 복사본"이라 데이터가 바뀌어도 그대로 남음
    /// → 같은 ID가 있으면 최신으로 바꾸고, 없어진 지역(예전 大阪市 전체 데이터)이면 다시 등록 요청
    private func refreshAreaFromLatestData() {
        guard let current = settings.selectedArea,
              !current.isCustom,                 // 직접 설정한 지역은 그대로
              let data = GomiData.shared else { return }
        if let latest = data.areas.first(where: { $0.id == current.id }) {
            if latest != current { settings.selectedArea = latest }   // onChange → 저장 + 위젯 갱신
        } else {
            settings.selectedArea = nil
            showReRegisterAlert = true
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch settings.colorScheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
