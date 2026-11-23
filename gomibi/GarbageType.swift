//
//  GarbageType.swift
//  GomiDay
//

import SwiftUI

/// 쓰레기 종류
enum GarbageType: String, Codable, CaseIterable, Identifiable {
    case burnable = "可燃ごみ"      // 가연 쓰레기
    case nonBurnable = "不燃ごみ"   // 불연 쓰레기
    case resource = "資源ごみ"      // 자원 (캔·병·페트병)
    case plastic = "プラスチック"    // 플라스틱
    case paper = "古紙"             // 고지(헌 종이)
    
    var id: String { rawValue }
    
    /// 데이터 파일에서 쓰는 영문 키 ("burnable" 등)
    var key: String {
        switch self {
        case .burnable: return "burnable"
        case .nonBurnable: return "nonBurnable"
        case .resource: return "resource"
        case .plastic: return "plastic"
        case .paper: return "paper"
        }
    }
    
    /// JSON 읽기: "burnable"(영문 키)와 "可燃ごみ"(일본어 값) 둘 다 허용
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "burnable", "可燃ごみ":       self = .burnable
        case "nonBurnable", "不燃ごみ":    self = .nonBurnable
        case "resource", "資源", "資源ごみ": self = .resource   // 예전 저장값 "資源"도 허용
        case "plastic", "プラスチック":     self = .plastic
        case "paper", "古紙":             self = .paper
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "알 수 없는 쓰레기 종류: \(value)"))
        }
    }
    
    /// SF Symbol 아이콘
    var icon: String {
        switch self {
        case .burnable: return "flame.fill"
        case .nonBurnable: return "trash.fill"
        case .resource: return "arrow.3.trianglepath"
        case .plastic: return "bag.fill"
        case .paper: return "newspaper.fill"
        }
    }
    
    /// 포인트 컬러 (ColorAssets.swift에 코드로 정의 → 에셋 없이도 항상 표시됨)
    var color: Color {
        switch self {
        case .burnable: return .burnableColor
        case .nonBurnable: return .nonBurnableColor
        case .resource: return .resourceColor
        case .plastic: return .plasticColor
        case .paper: return .paperColor
        }
    }
    
    /// 짧은 이름 (위젯·달력용)
    var shortName: String {
        switch self {
        case .burnable: return "可燃"
        case .nonBurnable: return "不燃"
        case .resource: return "資源"
        case .plastic: return "プラ"
        case .paper: return "古紙"
        }
    }
    
    /// 무엇을 버리는지 간단 설명
    var examples: String {
        switch self {
        case .burnable: return "生ごみ・紙くず・衣類など"
        case .nonBurnable: return "金属・ガラス・陶器など"
        case .resource: return "缶・びん・ペットボトル"
        case .plastic: return "プラマークのある容器包装"
        case .paper: return "新聞・雑誌・段ボール"
        }
    }
}
