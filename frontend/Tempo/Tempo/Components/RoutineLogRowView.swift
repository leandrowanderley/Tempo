//
//  RoutineLogRowView.swift
//  Tempo
//
//  Uma linha do dia selecionado no calendário de Histórico: rotina, horário e se foi
//  feita naquele dia (03-calendario-historico-ui.md §3).
//

import SwiftUI

struct RoutineLogRowView: View {
    let log: RoutineLog

    private var dotColor: Color {
        log.type == .workout ? .tempoStrava : .catHabit
    }

    private var statusIconName: String {
        log.completed ? "checkmark.circle.fill" : "xmark.circle"
    }

    private var statusIconColor: Color {
        log.completed ? .tempoTextPrimary : .tempoTextSecondary
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(dotColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.name)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)

                Text(log.loggedAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.tempoTextSecondary)
            }

            Spacer()

            Image(systemName: statusIconName)
                .font(.title3)
                .foregroundColor(statusIconColor)
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 10) {
        RoutineLogRowView(log: RoutineLog(id: "1", routineId: "r1", name: "Corrida", type: .workout, loggedAt: Date(), completed: true))
        RoutineLogRowView(log: RoutineLog(id: "2", routineId: "h1", name: "Meditação", type: .habit, loggedAt: Date(), completed: false))
    }
    .padding()
    .background(Color.tempoBackground)
}
