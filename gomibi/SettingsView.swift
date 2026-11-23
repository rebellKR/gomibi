//
//  SettingsView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI
import WidgetKit

/// 설정 화면
struct SettingsView: View {
    
    @Binding var settings: UserSettings
    @State private var showingResetAlert = false
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var pendingNotificationCount = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                List {
                    // 등록 지역 섹션
                    registeredAreaSection
                    
                    // 수거 시각 설정
                    collectionTimeSection
                    
                    // 알림 설정
                    notificationSection
                    
                    // 외관 설정
                    appearanceSection
                    
                    // 앱 정보
                    appInfoSection
                    
                    // 데이터 초기화
                    resetSection
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .alert("データを初期化", isPresented: $showingResetAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("初期化", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("すべてのデータを削除しますか？")
            }
        }
    }
    
    // MARK: - 등록 지역 섹션
    
    private var registeredAreaSection: some View {
        Section {
            if let area = settings.selectedArea {
                VStack(alignment: .leading, spacing: 8) {
                    Text(area.displayName)
                        .font(.headline)
                    
                    Text("\(area.rules.count)種類のゴミ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // 쓰레기 종류 표시
                    FlowLayout(spacing: 8) {
                        ForEach(area.rules, id: \.id) { rule in
                            HStack(spacing: 4) {
                                Image(systemName: rule.type.icon)
                                    .font(.caption2)
                                Text(rule.type.shortName)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(rule.type.color.opacity(0.2))
                            .cornerRadius(6, antialiased: true)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
                
                Button {
                    clearArea()
                } label: {
                    Text("地域を変更")
                        .foregroundColor(.red)
                }
            } else {
                Text("地域が登録されていません")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("登録地域")
        }
    }
    
    // MARK: - 수거 시각 설정
    
    private var collectionTimeSection: some View {
        Section {
            HStack {
                Text("収集締切時刻")
                Spacer()
                Text(settings.collectionDeadline.displayString)
                    .foregroundStyle(.secondary)
            }
            
            // 시간 선택 (임시로 고정 옵션)
            Picker("時", selection: Binding(
                get: { settings.collectionDeadline.hour },
                set: { newHour in
                    settings.collectionDeadline = TimeOfDay(
                        hour: newHour,
                        minute: settings.collectionDeadline.minute
                    )
                    saveSettings()
                }
            )) {
                ForEach(6..<12) { hour in
                    Text("\(hour)時").tag(hour)
                }
            }
            .pickerStyle(.menu)
            
            Picker("分", selection: Binding(
                get: { settings.collectionDeadline.minute },
                set: { newMinute in
                    settings.collectionDeadline = TimeOfDay(
                        hour: settings.collectionDeadline.hour,
                        minute: newMinute
                    )
                    saveSettings()
                }
            )) {
                Text("00分").tag(0)
                Text("30分").tag(30)
            }
            .pickerStyle(.menu)
        } header: {
            Text("収集時刻")
        } footer: {
            Text("この時刻以降は、当日の収集予定が表示されなくなります")
        }
    }
    
    // MARK: - 외관 설정
    
    private var notificationSection: some View {
        Section {
            // 알림 활성화
            Toggle("前日夜に通知", isOn: Binding(
                get: { settings.notificationEnabled },
                set: { newValue in
                    settings.notificationEnabled = newValue
                    if newValue {
                        Task {
                            // 권한 요청
                            let granted = await notificationManager.requestAuthorization()
                            if granted {
                                await notificationManager.scheduleDailyNotifications(settings: settings)
                                await updateNotificationCount()
                            }
                        }
                    } else {
                        notificationManager.cancelAllNotifications()
                    }
                    saveSettings()
                }
            ))
            
            if settings.notificationEnabled {
                // 알림 시각
                Picker("通知時刻", selection: Binding(
                    get: { settings.notificationTime.hour },
                    set: { newHour in
                        settings.notificationTime = TimeOfDay(
                            hour: newHour,
                            minute: settings.notificationTime.minute
                        )
                        Task {
                            await notificationManager.scheduleDailyNotifications(settings: settings)
                            await updateNotificationCount()
                        }
                        saveSettings()
                    }
                )) {
                    ForEach(18..<23) { hour in
                        Text("\(hour)時").tag(hour)
                    }
                }
                .pickerStyle(.menu)
                
                // 예정된 알림 개수
                if pendingNotificationCount > 0 {
                    HStack {
                        Text("予定された通知")
                        Spacer()
                        Text("\(pendingNotificationCount)件")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("通知")
        } footer: {
            Text("翌日がゴミ収集日の場合、前日夜に通知します")
        }
        .onAppear {
            Task {
                await updateNotificationCount()
            }
        }
    }
    
    // MARK: - 외관 설정
    
    private var appearanceSection: some View {
        Section {
            Picker("外観モード", selection: $settings.colorScheme) {
                ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                    Text(scheme.rawValue).tag(scheme)
                }
            }
            .onChange(of: settings.colorScheme) { _, _ in
                saveSettings()
            }
        } header: {
            Text("外観")
        }
    }
    
    // MARK: - 앱 정보
    
    private var appInfoSection: some View {
        Section {
            HStack {
                Text("バージョン")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Text("GitHub")
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("アプリ情報")
        }
    }
    
    // MARK: - 데이터 초기화
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Text("すべてのデータを初期化")
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveSettings() {
        AppGroupStorage.saveSettings(settings)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func clearArea() {
        settings.selectedArea = nil
        saveSettings()
    }
    
    private func resetData() {
        AppGroupStorage.clearAllData()
        settings = UserSettings()
        notificationManager.cancelAllNotifications()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func updateNotificationCount() async {
        pendingNotificationCount = await notificationManager.getPendingNotificationCount()
    }
}

// MARK: - FlowLayout (가로로 흐르는 레이아웃)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    SettingsView(settings: .constant(UserSettings(
        selectedArea: Area(
            id: "test",
            prefecture: "東京都",
            city: "世田谷区",
            cityKana: "せたがやく",
            area: "三軒茶屋",
            rules: [
                GarbageScheduleRule(type: .burnable, weekdays: [2, 5]),
                GarbageScheduleRule(type: .plastic, weekdays: [3]),
                GarbageScheduleRule(type: .resource, weekdays: [4], weeks: [2, 4])
            ],
            exceptions: [],
            source: nil,
            updated: nil
        )
    )))
}
