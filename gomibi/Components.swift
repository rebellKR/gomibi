//
//  Components.swift
//  GomiDay
//
//  여러 화면에서 같이 쓰는 작은 UI 부품
//

import SwiftUI

// MARK: - 카드 스타일

extension View {
    /// 둥근 카드 배경
    func card(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - 쓰레기 종류 아이콘 (색 원 안의 아이콘)

struct GarbageIcon: View {
    let type: GarbageType
    var size: CGFloat = 36
    
    var body: some View {
        Image(systemName: type.icon)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(type.color.gradient, in: Circle())
            .accessibilityLabel(type.rawValue)
    }
}

// MARK: - 쓰레기 종류 칩 ("🔥 可燃")

struct GarbageChip: View {
    let type: GarbageType
    var long = false
    var label: String? = nil      // 지역별 이름 (있으면 우선)
    
    var body: some View {
        Label(label ?? (long ? type.rawValue : type.shortName), systemImage: type.icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - 규칙 한 줄 (아이콘 + 이름 + "毎週 火・金曜")

struct RuleRow: View {
    let rule: GarbageScheduleRule
    var name: String? = nil       // 지역별 이름
    
    var body: some View {
        HStack(spacing: 12) {
            GarbageIcon(type: rule.type)
            VStack(alignment: .leading, spacing: 2) {
                Text(name ?? rule.type.rawValue).font(.headline)
                Text(rule.type.examples).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(rule.scheduleText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(rule.type.color)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FlowLayout (가로로 채우고 넘치면 줄바꿈)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.replacingUnspecifiedDimensions().width, subviews: subviews).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(width: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let p = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified)
        }
    }
    
    private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        var positions: [CGPoint] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {   // 줄바꿈
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (CGSize(width: width, height: y + lineHeight), positions)
    }
}
