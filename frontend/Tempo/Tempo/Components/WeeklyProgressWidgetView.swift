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
    let streakWeeks: Int

    private var motivationalMessage: String {
        HabitStreakMessages.message(forWeeks: streakWeeks)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                HStack(spacing: 4) {
                    Image(systemName: "balloon") // "bolt", "balloon", "flame.fill"
                        .font(.largeTitle)
                        .foregroundColor(streakWeeks >= 1 ? .orange : Color(.systemGray3))
                    Text("\(streakWeeks)")
                        .font(.title.weight(.bold))
                        .foregroundColor(streakWeeks >= 1 ? .orange : .tempoTextSecondary)
                }
//                Image(systemName: "figure.run")
//                    .foregroundColor(.tempoStrava)
                Text(motivationalMessage)
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)
                //Spacer()

//                HStack(spacing: 4) {
//                    Image(systemName: "balloon") // "bolt", "balloon", "flame.fill"
//                        .font(.largeTitle)
//                        .foregroundColor(streakWeeks >= 1 ? .orange : Color(.systemGray3))
//                    Text("\(streakWeeks)")
//                        .font(.title.weight(.bold))
//                        .foregroundColor(streakWeeks >= 1 ? .orange : .tempoTextSecondary)
//                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(routines) { routine in
                        VStack(spacing: 10) {
                            ZStack {
                                ProgressRingView(
                                    progress: routine.progress,
                                    color: routine.type == .workout ? .tempoStrava : .catHabit,
                                    lineWidth: 7
                                )
                                .frame(width: 58, height: 58)

                                Text("\(Int((routine.progress * 100).rounded()))%")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.tempoTextPrimary)
                            }

                            VStack(spacing: 2) {
                                Text(routine.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.tempoTextPrimary)
                                    .lineLimit(1)

                                Text("\(routine.currentCount)/\(routine.targetCount)")
                                    .font(.caption2)
                                    .foregroundColor(.tempoTextSecondary)
                            }
                        }
                        .frame(width: 66)
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
        .padding(20)
        .background(Color.tempoCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.tempoBorder, lineWidth: 1)
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
        streakWeeks: 5
    )
    .padding()
    .background(Color.tempoBackground)
}
