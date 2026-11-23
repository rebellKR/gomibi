//
//  AreaSearchView.swift
//  GomiDay
//
//  지역 검색 → 상세(달력) 확인 → 등록. 데이터가 없는 곳은 직접 설정.
//

import SwiftUI

struct AreaSearchView: View {
    
    var currentArea: Area?
    let onSelect: (Area) -> Void          // 지역을 고르면 호출
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let data = GomiData.shared
    
    var body: some View {
        NavigationStack {
            List {
                if data == nil {
                    ContentUnavailableView("データを読み込めませんでした", systemImage: "exclamationmark.triangle")
                }
                if query.isEmpty {
                    // 도도부현별 시구정촌 목록
                    ForEach(groupedMunicipalities, id: \.prefecture) { group in
                        Section(group.prefecture) {
                            ForEach(group.items) { m in
                                NavigationLink(value: m) { municipalityRow(m) }
                            }
                        }
                    }
                } else {
                    // 검색: 시구정촌 + 동네(町名) 둘 다
                    let ms = groupedMunicipalities.flatMap(\.items)
                    if !ms.isEmpty {
                        Section("市区町村") {
                            ForEach(ms) { m in NavigationLink(value: m) { municipalityRow(m) } }
                        }
                    }
                    if !matchedAreas.isEmpty {
                        Section("町名・地区") {
                            ForEach(matchedAreas) { area in
                                NavigationLink { detail(area) } label: { AreaRow(area: area, showCity: true) }
                            }
                        }
                    }
                }
            }
            .overlay {
                if !query.isEmpty && groupedMunicipalities.isEmpty && matchedAreas.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .navigationTitle("地域を選択")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "市区町村・町名で検索（例: 万代）")
            .navigationDestination(for: Municipality.self) { m in
                destination(for: m)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
    
    private var query: String { searchText.trimmingCharacters(in: .whitespaces) }
    
    // MARK: - 행
    
    private func municipalityRow(_ m: Municipality) -> some View {
        let hasData = !(data?.areas(for: m).isEmpty ?? true)
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(m.city).font(.body.weight(.medium))
                Text(m.cityKana).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if currentArea?.city == m.city && currentArea?.prefecture == m.prefecture {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
            } else if !hasData {
                Text("手動設定").font(.caption2).foregroundStyle(.secondary)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }
        }
    }
    
    // MARK: - 이동할 화면
    
    @ViewBuilder
    private func destination(for m: Municipality) -> some View {
        let areas = data?.areas(for: m) ?? []
        if areas.isEmpty {
            customEditor(m)
        } else if areas.count == 1, let area = areas.first {
            detail(area)
        } else if areas.contains(where: { $0.ward != nil }) {
            // 大阪市처럼 구가 있는 도시 → 구 선택부터
            WardListView(municipality: m, areas: areas, currentArea: currentArea,
                         detail: detail, customEditor: { customEditor(m) })
        } else {
            AreaListView(title: m.city, areas: areas, currentArea: currentArea, detail: detail)
        }
    }
    
    private func detail(_ area: Area) -> AreaDetailView {
        AreaDetailView(area: area, isCurrent: area.id == currentArea?.id) { select(area) }
    }
    
    private func customEditor(_ m: Municipality) -> CustomAreaEditorView {
        CustomAreaEditorView(prefecture: m.prefecture, city: m.city, cityKana: m.cityKana) { select($0) }
    }
    
    private func select(_ area: Area) {
        onSelect(area)
        dismiss()
    }
    
    // MARK: - 검색
    
    private var groupedMunicipalities: [PrefectureGroup] {
        let all = data?.municipalities ?? []
        let filtered = query.isEmpty ? all : all.filter { $0.matchesSearch(query) }
        // 코드 순서(북→남)를 유지하면서 도도부현별로 묶기
        var order: [String] = []
        var dict: [String: [Municipality]] = [:]
        for m in filtered {
            if dict[m.prefecture] == nil { order.append(m.prefecture) }
            dict[m.prefecture, default: []].append(m)
        }
        return order.map { PrefectureGroup(prefecture: $0, items: dict[$0] ?? []) }
    }
    
    /// 동네 이름 검색 (최대 80건)
    private var matchedAreas: [Area] {
        guard !query.isEmpty, let data else { return [] }
        return Array(data.areas.lazy.filter { $0.matches(query) }.prefix(80))
    }
}

/// 도도부현 1개 + 그 안의 시구정촌들
struct PrefectureGroup {
    let prefecture: String
    let items: [Municipality]
}

// MARK: - 구 목록 (大阪市 → 阿倍野区 …)

struct WardListView<Detail: View, Editor: View>: View {
    let municipality: Municipality
    let areas: [Area]
    var currentArea: Area?
    let detail: (Area) -> Detail
    let customEditor: () -> Editor
    
    var body: some View {
        List {
            Section {
                ForEach(wards, id: \.self) { ward in
                    NavigationLink {
                        AreaListView(title: ward, areas: areas.filter { $0.ward == ward },
                                     currentArea: currentArea, detail: detail)
                    } label: {
                        HStack {
                            Text(ward)
                            Spacer()
                            if currentArea?.ward == ward && currentArea?.city == municipality.city {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            } footer: {
                Text("区によって、さらに町丁目・番地ごとに収集日が異なります。")
            }
            Section {
                NavigationLink("見つからない場合は手動で設定", destination: customEditor)
            }
        }
        .navigationTitle(municipality.city)
    }
    
    /// 데이터 순서 그대로 중복 없이
    private var wards: [String] {
        var seen = Set<String>()
        return areas.compactMap(\.ward).filter { seen.insert($0).inserted }
    }
}

// MARK: - 지구 목록 (町丁目)

struct AreaListView<Detail: View>: View {
    let title: String
    let areas: [Area]
    var currentArea: Area?
    let detail: (Area) -> Detail
    
    @State private var searchText = ""
    
    var body: some View {
        List(filtered) { area in
            NavigationLink { detail(area) } label: {
                HStack {
                    AreaRow(area: area)
                    if area.id == currentArea?.id {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .overlay {
            if filtered.isEmpty { ContentUnavailableView.search(text: searchText) }
        }
        .searchable(text: $searchText, prompt: "町名で絞り込み")
        .navigationTitle(title)
    }
    
    private var filtered: [Area] {
        let q = searchText.trimmingCharacters(in: .whitespaces)
        return q.isEmpty ? areas : areas.filter { $0.matches(q) }
    }
}

// MARK: - 지구 1행 (이름 + 쓰레기 칩)

struct AreaRow: View {
    let area: Area
    var showCity = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(area.area ?? area.city).font(.headline)
            if showCity {
                Text([area.city, area.ward].compactMap { $0 }.joined(separator: " "))
                    .font(.caption).foregroundStyle(.secondary)
            }
            FlowLayout(spacing: 6) {
                ForEach(area.rules) { rule in
                    // 칩: "普通 水土"
                    Label("\(area.shortName(for: rule.type)) \(rule.weekdays.map { Weekday.shortName($0) }.joined())",
                          systemImage: rule.type.icon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(rule.type.color)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(rule.type.color.opacity(0.15), in: Capsule())
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 지역 상세 (규칙 + 달력 + 출처 + 등록 버튼)

struct AreaDetailView: View {
    let area: Area
    var isCurrent = false
    var onSelect: (() -> Void)? = nil     // nil이면 보기 전용
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 헤더
                VStack(alignment: .leading, spacing: 4) {
                    Text([area.prefecture, area.city, area.ward].compactMap { $0 }.joined(separator: " "))
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text(area.area ?? area.city)
                        .font(.title.bold())
                    if isCurrent {
                        Label("登録中の地域", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                
                // 수거 규칙
                VStack(alignment: .leading, spacing: 8) {
                    Text("収集日").font(.headline)
                    if area.rules.isEmpty {
                        Text("収集日が設定されていません").foregroundStyle(.secondary)
                    }
                    ForEach(area.rules) { rule in
                        RuleRow(rule: rule, name: area.name(for: rule.type))
                        if rule.id != area.rules.last?.id { Divider() }
                    }
                }
                .card()
                
                if let note = area.note {
                    Label(note, systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .card()
                }
                
                // 달력
                MonthCalendarView(area: area).card()
                
                // 출처
                if let source = area.source, let url = URL(string: source) {
                    VStack(alignment: .leading, spacing: 8) {
                        Link(destination: url) {
                            Label("自治体の公式ページで確認", systemImage: "safari")
                        }
                        Text("収集日は変更されることがあります。地区によって異なる場合があるため、必ず公式情報もご確認ください。"
                             + (area.updated.map { "（データ更新: \($0)）" } ?? ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .card()
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(area.ward ?? area.city)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let onSelect, !isCurrent {
                Button(action: onSelect) {
                    Text("この地域を登録").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(.bar)
            }
        }
    }
}
