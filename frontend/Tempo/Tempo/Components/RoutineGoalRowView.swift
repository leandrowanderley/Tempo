//
//  RoutineGoalRowView.swift
//  Tempo
//
//  Linha de meta semanal com steppers (—/+), usada no Routine Planner (project.md §3.4).
//  Mexe em targetCount (a meta), não em currentCount (isso é o progresso, mostrado na Home).
//

import SwiftUI

struct RoutineGoalRowView: View {
    @Binding var routine: Routine

    var body: some View {
        HStack {
            Text(routine.title)
                .font(.body)
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            HStack(spacing: 16) {
                stepperButton(systemName: "minus") {
                    if routine.targetCount > 0 { routine.targetCount -= 1 }
                }

                Text("\(routine.targetCount)")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.tempoTextPrimary)
                    .frame(minWidth: 16)

                stepperButton(systemName: "plus") {
                    routine.targetCount += 1
                }
            }
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.tempoPrimary)
                .frame(width: 26, height: 26)
                .background(Color.tempoBackground)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var routine = Routine(id: "1", title: "Corrida", type: .workout, targetCount: 3, currentCount: 2)

    RoutineGoalRowView(routine: $routine)
        .padding()
        .background(Color.tempoBackground)
}
