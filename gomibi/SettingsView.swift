//
//  SettingsView.swift
//  GomiDay
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var settings: UserSettings
    @State private var showingSearch = false
    @State private var showingResetAlert = false
    @State private var showingWidgetGuide = false
    @State private var notificationDenied = false
    @State private var pendingCount = 0
    
    var body: some View {
        NavigationStack {
            Form {
                areaSection
                timeSection
                notificationSection
                widgetSection
                appearanceSection
                aboutSection
                
                Section {
                    Button("すべてのデータを初期化", role: .destructive) { showingResetAlert = true }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showingSearch) {
                AreaSearchView(currentArea: settings.selectedArea) { settings.selectedArea = $0 }
            }
            .sheet(isPresented: $showingWidgetGuide) { WidgetGuideView() }
            .alert("データを初期化", isPresented: $showingResetAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("初期化", role: .destructive) {
                    AppGroupStorage.clearAllData()
                    settings = UserSettings()
                }
            } message: {
                Text("登録地域と設定がすべて削除されます。")
            }
            .task(id: settings) { pendingCount = await NotificationManager.pendingCount() }
        }
    }
    
    // MARK: - 지역
    
    private var areaSection: some View {
        Section("登録地域") {
            if let area = settings.selectedArea {
                NavigationLink {
                    AreaDetailView(area: area, isCurrent: true)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(area.displayName).font(.headline)
                        FlowLayout(spacing: 6) {
                            ForEach(area.rules) { GarbageChip(type: $0.type, label: area.shortName(for: $0.type)) }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if area.isCustom {
                    NavigationLink("収集日を編集") {
                        CustomAreaEditorView(prefecture: area.prefecture, city: area.city,
                                             cityKana: area.cityKana, existing: area) { updated in
                            settings.selectedArea = updated
                        }
                    }
                }
                Button("地域を変更") { showingSearch = true }
            } else {
                Button("地域を登録") { showingSearch = true }
            }
        }
    }
    
    // MARK: - 마감 시각
    
    private var timeSection: some View {
        Section {
            DatePicker("ゴミ出しの締切",
                       selection: Binding(
                        get: { settings.collectionDeadline.asDate },
                        set: { settings.collectionDeadline = TimeOfDay(date: $0) }),
                       displayedComponents: .hourAndMinute)
        } footer: {
            Text("この時刻を過ぎると、今日の予定は「次の収集日」に切り替わります。")
        }
    }
    
    // MARK: - 알림
    
    private var notificationSection: some View {
        Section {
            Toggle("前日の夜に通知", isOn: Binding(
                get: { settings.notificationEnabled },
                set: { newValue in
                    if newValue {
                        Task {
                            let granted = await NotificationManager.requestAuthorization()
                            settings.notificationEnabled = granted
                            notificationDenied = !granted
                        }
                    } else {
                        settings.notificationEnabled = false
                    }
                }))
            
            if settings.notificationEnabled {
                DatePicker("通知時刻",
                           selection: Binding(
                            get: { settings.notificationTime.asDate },
                            set: { settings.notificationTime = TimeOfDay(date: $0) }),
                           displayedComponents: .hourAndMinute)
                LabeledContent("予約中の通知", value: "\(pendingCount)件")
            }
            
            if notificationDenied {
                Button("通知が許可されていません（設定を開く）") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.footnote)
            }
        } header: {
            Text("通知")
        } footer: {
            Text("翌日が収集日のとき、前日の指定時刻にお知らせします。")
        }
    }
    
    // MARK: - 위젯
    
    private var widgetSection: some View {
        Section {
            Button {
                showingWidgetGuide = true
            } label: {
                Label("ウィジェットの追加方法", systemImage: "rectangle.on.rectangle")
            }
            if !AppGroupStorage.isAppGroupAvailable {
                Label("App Groupが無効のため、ウィジェットに地域が反映されません", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        } header: {
            Text("ウィジェット")
        }
    }
    
    // MARK: - 외관
    
    private var appearanceSection: some View {
        Section("外観") {
            Picker("外観モード", selection: $settings.colorScheme) {
                ForEach(AppColorScheme.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - 앱 정보
    
    private var aboutSection: some View {
        Section {
            LabeledContent("バージョン", value: appVersion)
        } header: {
            Text("アプリ情報")
        } footer: {
            Text("収集日のデータは各自治体の公開情報をもとにしています。祝日・年末年始は自治体の案内をご確認ください。")
        }
    }
    
    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(v) (\(b))"
    }
}

// MARK: - 위젯 추가 방법 안내

struct WidgetGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("ロック画面") {
                    step(1, "ロック画面を長押し")
                    step(2, "「カスタマイズ」→「ロック画面」をタップ")
                    step(3, "時計の下の枠をタップ")
                    step(4, "「GomiDay」を選んで、好きな形を追加")
                }
                Section("ホーム画面") {
                    step(1, "ホーム画面の空いている所を長押し")
                    step(2, "左上の「編集」→「ウィジェットを追加」")
                    step(3, "「GomiDay」を検索して追加")
                }
                Section {
                    Text("ウィジェットが一覧に出ないときは、アプリを一度開いてから、iPhoneを再起動してみてください。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("ウィジェットの追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("閉じる") { dismiss() } }
            }
        }
    }
    
    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.accentColor, in: Circle())
            Text(text)
        }
    }
}
