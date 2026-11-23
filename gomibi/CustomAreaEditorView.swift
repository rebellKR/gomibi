//
//  CustomAreaEditorView.swift
//  GomiDay
//
//  데이터가 없는 지역: 수거일을 직접 입력
//

import SwiftUI

struct CustomAreaEditorView: View {
    
    let prefecture: String
    let city: String
    let cityKana: String
    var existing: Area? = nil            // 수정할 때 기존 지역
    let onSave: (Area) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var areaName = ""
    @State private var rules: [GarbageScheduleRule] = []
    @State private var editingRule: GarbageScheduleRule?   // 편집 시트
    @State private var loaded = false
    
    var body: some View {
        Form {
            Section {
                LabeledContent("市区町村", value: "\(prefecture) \(city)")
                TextField("地区名（任意）例: 三軒茶屋1丁目", text: $areaName)
            } footer: {
                Text("この地域はまだデータがありません。自治体のゴミ収集カレンダーを見ながら入力してください。")
            }
            
            Section("収集日") {
                ForEach(rules) { rule in
                    Button { editingRule = rule } label: { RuleRow(rule: rule) }
                        .foregroundStyle(.primary)
                }
                .onDelete { rules.remove(atOffsets: $0) }
                
                Button {
                    // 아직 없는 종류를 기본값으로
                    let used = Set(rules.map(\.type))
                    let type = GarbageType.allCases.first { !used.contains($0) } ?? .burnable
                    editingRule = GarbageScheduleRule(type: type, weekdays: [])
                } label: {
                    Label("ゴミの種類を追加", systemImage: "plus.circle.fill")
                }
            }
            
            if !rules.isEmpty {
                Section("プレビュー") {
                    MonthCalendarView(area: buildArea())
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(existing == nil ? "収集日を設定" : "収集日を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { onSave(buildArea()) }
                    .disabled(rules.isEmpty)
            }
        }
        .sheet(item: $editingRule) { rule in
            RuleEditorView(rule: rule) { updated in
                if let i = rules.firstIndex(where: { $0.id == updated.id }) {
                    rules[i] = updated
                } else {
                    rules.append(updated)
                }
            }
        }
        .onAppear {
            // 수정 모드면 기존 값 채우기 (처음 한 번만)
            guard !loaded else { return }
            loaded = true
            if let existing {
                rules = existing.rules
                areaName = existing.area ?? ""
            }
        }
    }
    
    private func buildArea() -> Area {
        Area(
            id: existing?.id ?? "custom-\(UUID().uuidString)",
            prefecture: prefecture,
            city: city,
            cityKana: cityKana,
            area: areaName.isEmpty ? nil : areaName,
            rules: rules,
            exceptions: [],
            source: nil,          // 출처 없음 = 직접 설정
            updated: nil
        )
    }
}

// MARK: - 규칙 1개 편집

struct RuleEditorView: View {
    
    @State var rule: GarbageScheduleRule
    let onDone: (GarbageScheduleRule) -> Void
    @Environment(\.dismiss) private var dismiss
    
    /// 매주인지, 제n주인지
    @State private var everyWeek = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("種類") {
                    Picker("種類", selection: $rule.type) {
                        ForEach(GarbageType.allCases) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                Section("曜日") {
                    HStack(spacing: 6) {
                        ForEach(Weekday.all, id: \.self) { wd in
                            let on = rule.weekdays.contains(wd)
                            Button {
                                toggle(&rule.weekdays, wd)
                            } label: {
                                Text(Weekday.shortName(wd))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .foregroundStyle(on ? Color.white : Color.primary)
                                    .background(on ? rule.type.color : Color.secondary.opacity(0.12),
                                                in: RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section {
                    Picker("頻度", selection: $everyWeek) {
                        Text("毎週").tag(true)
                        Text("第◯週だけ").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    if !everyWeek {
                        HStack(spacing: 6) {
                            ForEach(1...5, id: \.self) { w in
                                let on = rule.weeks?.contains(w) ?? false
                                Button {
                                    var weeks = rule.weeks ?? []
                                    toggle(&weeks, w)
                                    rule.weeks = weeks
                                } label: {
                                    Text("第\(w)")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 36)
                                        .foregroundStyle(on ? Color.white : Color.primary)
                                        .background(on ? rule.type.color : Color.secondary.opacity(0.12),
                                                    in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } header: {
                    Text("頻度")
                } footer: {
                    Text(rule.weekdays.isEmpty ? "曜日を選んでください" : previewRule.scheduleText)
                }
            }
            .navigationTitle("収集日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { onDone(previewRule); dismiss() }
                        .disabled(rule.weekdays.isEmpty || (!everyWeek && (rule.weeks ?? []).isEmpty))
                }
            }
            .onAppear { everyWeek = (rule.weeks ?? []).isEmpty }
        }
        .presentationDetents([.large])
    }
    
    /// 저장될 규칙 (매주면 weeks 비움)
    private var previewRule: GarbageScheduleRule {
        var r = rule
        if everyWeek { r.weeks = nil }
        r.weekdays.sort()
        r.weeks?.sort()
        return r
    }
    
    private func toggle(_ list: inout [Int], _ value: Int) {
        if let i = list.firstIndex(of: value) { list.remove(at: i) } else { list.append(value) }
    }
}
