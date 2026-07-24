//
//  PeriodGoalRowView.swift
//  Tempo
//
//  Linha "– texto" de uma intenção geral do mês (nem Evento nem Tarefa). Um único
//  alvo de toque — abre as opções de renomear/excluir, não uma edição completa.
//

import SwiftUI

struct PeriodGoalRowView: View {
    let goal: PeriodGoal
    let font: Font
    let symbolSize: CGFloat
    var onTap: (PeriodGoal) -> Void

    var body: some View {
        Button {
            onTap(goal)
        } label: {
            HStack(alignment: .top, spacing: 4) {
                Text("–")
                    .font(.system(size: symbolSize, weight: .medium, design: .monospaced))
                    .foregroundColor(.tempoTextSecondary)
                    .frame(width: symbolSize, height: symbolSize)

                Text(goal.title)
                    .font(font)
                    .foregroundColor(.tempoTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Nota: \(goal.title)")
    }
}

#Preview {
    PeriodGoalRowView(
        goal: PeriodGoal(id: "1", title: "Quero socializar mais", month: Date()),
        font: .subheadline,
        symbolSize: 14,
        onTap: { _ in }
    )
    .padding()
    .background(Color.tempoBackground)
}
