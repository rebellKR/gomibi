//
//  Area.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// 지역 정보 (쓰레기 수거 일정 포함)
struct Area: Codable, Identifiable, Equatable {
    let id: String               // 예: "13112-sangenjaya-1"
    let prefecture: String       // 도도부현: "東京都"
    let city: String             // 시구정촌: "世田谷区"
    let cityKana: String         // 히라가나: "せたがやく"
    let area: String?            // 지구/정목: "三軒茶屋1丁目" (옵션)
    let rules: [GarbageScheduleRule]  // 쓰레기 배출 규칙들
    let exceptions: [ScheduleException] // 예외 날짜들
    let source: String?          // 출처 URL
    let updated: String?         // 최종 업데이트 날짜
    var ward: String? = nil              // 행정구: "阿倍野区" (정령지정도시만)
    var note: String? = nil              // 주의사항 (예: 古紙는 コミュニティ回収)
    var typeNames: [String: String]? = nil      // 지역별 정식 명칭 (예: 大阪市 "普通ごみ")
    var typeShortNames: [String: String]? = nil // 지역별 짧은 이름 (예: "普通")
    
    /// 이 지역에서 부르는 쓰레기 이름
    func name(for type: GarbageType) -> String {
        typeNames?[type.key] ?? type.rawValue
    }
    
    /// 이 지역에서 부르는 짧은 이름
    func shortName(for type: GarbageType) -> String {
        typeShortNames?[type.key] ?? type.shortName
    }
    
    /// 화면 제목용 ("阿倍野区 万代1丁目" / "世田谷区")
    var title: String {
        [ward, area].compactMap { $0 }.joined(separator: " ").nonEmpty ?? city
    }
    
    /// 검색어가 동네·구 이름에 포함되는지
    func matches(_ query: String) -> Bool {
        (area?.contains(query) ?? false) || (ward?.contains(query) ?? false)
    }
    
    /// 직접 설정한 지역인지 (데이터 출처가 없음)
    var isCustom: Bool { source == nil }
    
    /// 표시명 (전체 주소)
    var displayName: String {
        [prefecture, city, ward, area].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

/// 시구정촌 목록 (전국 데이터)
struct Municipality: Codable, Identifiable, Hashable {
    let id: String           // 전국지방공공단체코드 (예: "13112")
    let prefecture: String   // "東京都"
    let prefectureKana: String // "とうきょうと"
    let city: String         // "世田谷区"
    let cityKana: String     // "せたがやく"
    
    /// 표시명
    var displayName: String {
        "\(prefecture) \(city)"
    }
    
    /// 검색용 문자열 (한자 + 히라가나)
    func matchesSearch(_ query: String) -> Bool {
        let lowercased = query.lowercased()
        return prefecture.lowercased().contains(lowercased) ||
               prefectureKana.contains(lowercased) ||
               city.lowercased().contains(lowercased) ||
               cityKana.contains(lowercased)
    }
}

/// 통합 데이터 파일(gomi_data.json)의 전체 구조
struct GomiData: Codable {
    let version: String
    let municipalities: [Municipality]  // 검색용 시구정촌 목록
    let areas: [Area]                   // 수거 일정이 등록된 지역
    
    /// 앱 실행 중 한 번만 읽어서 재사용
    static let shared: GomiData? = load()
    
    /// 이 시구정촌에 등록된 지역들
    func areas(for m: Municipality) -> [Area] {
        areas.filter { $0.prefecture == m.prefecture && $0.city == m.city }
    }
    
    /// 앱 번들에서 gomi_data.json 읽기 (실패 시 nil)
    static func load() -> GomiData? {
        guard let url = Bundle.main.url(forResource: "gomi_data", withExtension: "json") else {
            print("❌ gomi_data.json을 찾을 수 없습니다.")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(GomiData.self, from: data)
            print("✅ 시구정촌 \(decoded.municipalities.count)개 / 지역 \(decoded.areas.count)개 로드")
            return decoded
        } catch {
            print("❌ gomi_data.json 로드 실패: \(error)")
            return nil
        }
    }
}

extension String {
    /// 빈 문자열이면 nil
    var nonEmpty: String? { isEmpty ? nil : self }
}
