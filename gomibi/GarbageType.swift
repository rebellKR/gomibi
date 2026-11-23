//
//  GarbageType.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

/// 쓰레기 종류를 정의하는 열거형
enum GarbageType: String, Codable, CaseIterable, Identifiable {
    case burnable = "可燃ごみ"      // 가연 쓰레기
    case nonBurnable = "不燃ごみ"   // 불연 쓰레기
    case resource = "資源"          // 자원 쓰레기
    case plastic = "プラスチック"    // 플라스틱
    case paper = "古紙"             // 고지(헌 종이)
    
    var id: String { rawValue }
    
    /// JSON 읽기: "burnable"(영문 키)와 "可燃ごみ"(일본어 값) 둘 다 허용
    /// → 데이터 파일은 영문, 기존에 저장된 설정은 일본어여도 문제없이 읽힘
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        if let type = GarbageType(rawValue: value) {
            self = type
            return
        }
        switch value {
        case "burnable":    self = .burnable
        case "nonBurnable": self = .nonBurnable
        case "resource":    self = .resource
        case "plastic":     self = .plastic
        case "paper":       self = .paper
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "알 수 없는 쓰레기 종류: \(value)"))
        }
    }
    
    /// 종류별 SF Symbol 아이콘
    var icon: String {
        switch self {
        case .burnable: return "flame.fill"
        case .nonBurnable: return "trash.fill"
        case .resource: return "arrow.3.trianglepath"
        case .plastic: return "bag.fill"
        case .paper: return "doc.text.fill"
        }
    }
    
    /// 종류별 포인트 컬러 (Asset Catalog에서 정의)
    var colorName: String {
        switch self {
        case .burnable: return "BurnableColor"      // 코랄
        case .nonBurnable: return "NonBurnableColor" // 그레이
        case .resource: return "ResourceColor"       // 블루
        case .plastic: return "PlasticColor"         // 그린
        case .paper: return "PaperColor"             // 브라운
        }
    }
    
    /// SwiftUI Color 반환
    var color: Color {
        Color(colorName)
    }
    
    /// 짧은 표시명 (위젯용)
    var shortName: String {
        switch self {
        case .burnable: return "可燃"
        case .nonBurnable: return "不燃"
        case .resource: return "資源"
        case .plastic: return "プラ"
        case .paper: return "古紙"
        }
    }
}
