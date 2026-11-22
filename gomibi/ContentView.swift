//
//  ContentView.swift
//  GomiDay
//
//  Created by hyun_kim on 2026/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            Text("GomiDay")
                .font(.largeTitle)
                .bold()
            
            Text("쓰레기 배출일 알림 앱")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("🗑️ 1단계 완료!")
                .font(.title2)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
