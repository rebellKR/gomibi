//
//  AreaSearchView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI
import WidgetKit

/// 지역 검색 및 등록 화면
struct AreaSearchView: View {
    
    @Binding var settings: UserSettings
    @State private var searchText = ""
    @State private var municipalities: [Municipality] = []
    @State private var areas: [Area] = []
    @State private var selectedMunicipality: Municipality?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if selectedMunicipality == nil {
                        // 시구정촌 목록
                        municipalityList
                    } else {
                        // 해당 시구정촌의 지역 목록
                        areaList
                    }
                }
            }
            .navigationTitle(selectedMunicipality == nil ? "地域を選択" : selectedMunicipality!.city)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "市区町村を検索")
            .toolbar {
                if selectedMunicipality != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("戻る") {
                            selectedMunicipality = nil
                            searchText = ""
                        }
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
    }
    
    // MARK: - 시구정촌 목록
    
    private var municipalityList: some View {
        List {
            ForEach(filteredMunicipalities) { municipality in
                Button {
                    selectedMunicipality = municipality
                    searchText = ""
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(municipality.city)
                            .font(.headline)
                        Text(municipality.prefecture)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - 지역 목록
    
    private var areaList: some View {
        List {
            let municipalityAreas = areas.filter { area in
                guard let selected = selectedMunicipality else { return false }
                return area.city == selected.city && area.prefecture == selected.prefecture
            }
            
            if municipalityAreas.isEmpty {
                // 등록된 지역이 없으면 직접 설정 안내
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("この地域はまだ登録されていません")
                            .font(.headline)
                        
                        Text("収集日を直接設定することができます")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            createCustomArea()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("直接設定")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.burnableColor)
                            .cornerRadius(12, antialiased: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                // 등록된 지역 목록
                ForEach(municipalityAreas) { area in
                    Button {
                        selectArea(area)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            if let areaName = area.area {
                                Text(areaName)
                                    .font(.headline)
                            } else {
                                Text(area.city)
                                    .font(.headline)
                            }
                            
                            Text(area.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // 쓰레기 종류 표시
                            HStack(spacing: 6) {
                                ForEach(area.rules.prefix(3), id: \.id) { rule in
                                    Text(rule.type.shortName)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(rule.type.color.opacity(0.2))
                                        .cornerRadius(4, antialiased: true)
                                }
                                
                                if area.rules.count > 3 {
                                    Text("+\(area.rules.count - 3)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - 필터링된 시구정촌
    
    private var filteredMunicipalities: [Municipality] {
        if searchText.isEmpty {
            return municipalities
        } else {
            return municipalities.filter { $0.matchesSearch(searchText) }
        }
    }
    
    // MARK: - 데이터 로드
    
    /// 통합 파일 하나에서 시구정촌 + 지역 데이터를 함께 읽음
    private func loadData() {
        guard let data = GomiData.load() else { return }
        municipalities = data.municipalities
        areas = data.areas
    }
    
    // MARK: - 지역 선택
    
    private func selectArea(_ area: Area) {
        settings.selectedArea = area
        AppGroupStorage.saveSettings(settings)
        
        // 위젯 리로드
        WidgetCenter.shared.reloadAllTimelines()
        
        // 화면 닫기
        dismiss()
        
        print("✅ 지역 선택 완료: \(area.displayName)")
    }
    
    // MARK: - 커스텀 지역 생성
    
    private func createCustomArea() {
        guard let selected = selectedMunicipality else { return }
        
        // 빈 규칙으로 지역 생성 (나중에 직접 설정 화면으로 이동)
        let customArea = Area(
            id: UUID().uuidString,
            prefecture: selected.prefecture,
            city: selected.city,
            cityKana: selected.cityKana,
            area: nil,
            rules: [],  // 나중에 추가
            exceptions: [],
            source: nil,
            updated: nil
        )
        
        selectArea(customArea)
    }
}

#Preview {
    AreaSearchView(settings: .constant(UserSettings()))
}
