//
//  WeeklyProgressWidgetView.swift
//  Tempo
//

import SwiftUI

struct WeeklyProgressWidgetView: View {
    let routines: [Routine]
    let motivationalMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "figure.run")
                    .foregroundColor(.tempoStrava)
                Text(motivationalMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.tempoTextPrimary)
                Spacer()
            }

            HStack(spacing: 20) {
                ForEach(routines) { routine in
                    VStack(spacing: 8) {
                        ZStack {
                            ProgressRingView(
                                progress: routine.progress,
                                color: routine.type == .workout ? .tempoStrava : .catHabit
                            )
                            .frame(width: 56, height: 56)

                            Text("\(routine.currentCount)/\(routine.targetCount)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.tempoTextPrimary)
                        }

                        Text(routine.title)
                            .font(.caption2)
                            .foregroundColor(.tempoTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.tempoCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.tempoBorder, lineWidth: 1)
        )
    }
}

#Preview {
    WeeklyProgressWidgetView(
        routines: [
            Routine(id: "1", title: "Corrida", type: .workout, targetCount: 3, currentCount: 2),
            Routine(id: "2", title: "Superior", type: .workout, targetCount: 1, currentCount: 1),
            Routine(id: "3", title: "Meditação", type: .habit, targetCount: 5, currentCount: 2)
        ],
        motivationalMessage: "You're doing great!"
    )
    .padding()
    .background(Color.tempoBackground)
}
