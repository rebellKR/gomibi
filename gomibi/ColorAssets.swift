//
//  ColorAssets.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

extension Color {
    
    // MARK: - 쓰레기 종류별 포인트 컬러
    
    /// 가연 쓰레기 색상 (코랄)
    static let burnableColor = Color(
        light: Color(red: 1.0, green: 0.45, blue: 0.4),   // #FF7366
        dark: Color(red: 0.9, green: 0.4, blue: 0.35)     // #E56659
    )
    
    /// 불연 쓰레기 색상 (그레이)
    static let nonBurnableColor = Color(
        light: Color(red: 0.6, green: 0.6, blue: 0.62),   // #999A9E
        dark: Color(red: 0.7, green: 0.7, blue: 0.72)     // #B3B3B8
    )
    
    /// 자원 쓰레기 색상 (블루)
    static let resourceColor = Color(
        light: Color(red: 0.0, green: 0.48, blue: 1.0),   // #007AFF
        dark: Color(red: 0.04, green: 0.52, blue: 1.0)    // #0A84FF
    )
    
    /// 플라스틱 색상 (그린)
    static let plasticColor = Color(
        light: Color(red: 0.2, green: 0.78, blue: 0.35),  // #34C759
        dark: Color(red: 0.19, green: 0.82, blue: 0.35)   // #30D158
    )
    
    /// 고지 색상 (브라운)
    static let paperColor = Color(
        light: Color(red: 0.63, green: 0.49, blue: 0.37), // #A07D5E
        dark: Color(red: 0.68, green: 0.54, blue: 0.42)   // #AD8A6B
    )
    
    // MARK: - 배경 & 카드 색상
    
    /// 앱 배경 색상
    static let appBackground = Color(
        light: Color(red: 0.96, green: 0.96, blue: 0.97), // #F5F5F7
        dark: Color(red: 0.0, green: 0.0, blue: 0.0)      // #000000
    )
    
    /// 카드 배경 색상
    static let cardBackground = Color(
        light: Color.white,                                // #FFFFFF
        dark: Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E
    )
    
    /// 주요 텍스트 색상
    static let primaryText = Color(
        light: Color(red: 0.11, green: 0.11, blue: 0.12), // #1C1C1E
        dark: Color(red: 0.95, green: 0.95, blue: 0.97)   // #F2F2F7
    )
    
    /// 보조 텍스트 색상
    static let secondaryText = Color(
        light: Color(red: 0.56, green: 0.56, blue: 0.58), // #8E8E93
        dark: Color(red: 0.56, green: 0.56, blue: 0.58)   // #8E8E93
    )
    
    // MARK: - 헬퍼 초기화
    
    /// 라이트/다크 모드별 색상 초기화
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
