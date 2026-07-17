//
//  ProgressRingView.swift
//  Tempo
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 7

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(progress, 0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

#Preview {
    ProgressRingView(progress: 0.66, color: .catWorkout)
        .frame(width: 60, height: 60)
        .padding()
}
