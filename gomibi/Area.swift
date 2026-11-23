//
//  Area.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import Foundation

/// 지역 정보 (쓰레기 수거 일정 포함)
struct Area: Codable, Identifiable {
    let id: String               // 예: "13112-sangenjaya-1"
    let prefecture: String       // 도도부현: "東京都"
    let city: String             // 시구정촌: "世田谷区"
    let cityKana: String         // 히라가나: "せたがやく"
    let area: String?            // 지구/정목: "三軒茶屋1丁目" (옵션)
    let rules: [GarbageScheduleRule]  // 쓰레기 배출 규칙들
    let exceptions: [ScheduleException] // 예외 날짜들
    let source: String?          // 출처 URL
    let updated: String?         // 최종 업데이트 날짜
    
    /// 표시명 (전체 주소)
    var displayName: String {
        if let area = area, !area.isEmpty {
            return "\(prefecture) \(city) \(area)"
        } else {
            return "\(prefecture) \(city)"
        }
    }
}

/// 시구정촌 목록 (전국 데이터)
struct Municipality: Codable, Identifiable {
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
