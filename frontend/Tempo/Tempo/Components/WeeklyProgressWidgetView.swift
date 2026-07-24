//
//  WeeklyProgressWidgetView.swift
//  Tempo
//
//  Card com os anéis de progresso semanal das rotinas, exibido na Home.
//  Dados mockados por enquanto (ver RoutineMockData) — TODO: plugar em GET /routines.
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(routines) { routine in
                        VStack(spacing: 8) {
                            ZStack {
                                ProgressRingView(
                                    progress: routine.progress,
                                    color: routine.type == .workout ? .tempoStrava : .catHabit
                                )
                                .frame(width: 52, height: 52)

                                Text("\(routine.currentCount)/\(routine.targetCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.tempoTextPrimary)
                            }

                            Text(routine.title)
                                .font(.caption2)
                                .foregroundColor(.tempoTextSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.04),
                        .init(color: .black, location: 0.96),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
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
