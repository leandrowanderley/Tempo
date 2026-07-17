//
//  RoutineRowView.swift
//  Tempo
//
//  Card de meta de treino/hábito no Routine Planner — mesmo padrão visual do
//  FixedCommitmentRowView: bolinha de cor + nome à esquerda, dias das repetições à
//  direita. Toque abre o sheet de edição (nome, descrição, repetições, excluir).
//

import SwiftUI

struct RoutineRowView: View {
    let routine: Routine
    var onSave: (Routine) -> Void = { _ in }
    var onDelete: () -> Void = {}

    @State private var isShowingDetail = false

    private var dotColor: Color {
        routine.type == .workout ? .tempoStrava : .catHabit
    }

    var body: some View {
        Button {
            isShowingDetail = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)

                Text(routine.title)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)

                Spacer()

                if !routine.daysLabel.isEmpty {
                    Text(routine.daysLabel)
                        .font(.caption)
                        .foregroundColor(.tempoTextSecondary)
                }
            }
            .padding()
            .background(Color.tempoCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tempoBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingDetail) {
            RoutineFormView(existingRoutine: routine, type: routine.type, onSave: onSave, onDelete: onDelete)
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        RoutineRowView(routine: RoutineMockData.workouts[0])
        RoutineRowView(routine: RoutineMockData.habits[0])
    }
    .padding()
    .background(Color.tempoBackground)
}
