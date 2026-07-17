//
//  FixedCommitmentRowView.swift
//  Tempo
//
//  Card de Compromisso Fixo no Routine Planner — mesmo padrão visual/interativo do
//  EventCardView da Home: toque abre o sheet de edição (com opção de excluir).
//

import SwiftUI

struct FixedCommitmentRowView: View {
    let commitment: FixedCommitment
    var onSave: (FixedCommitment) -> Void = { _ in }
    var onDelete: () -> Void = {}

    @State private var isShowingDetail = false

    var body: some View {
        Button {
            isShowingDetail = true
        } label: {
            HStack(spacing: 12) {
                CategoryDotView(category: commitment.category)

                VStack(alignment: .leading, spacing: 4) {
                    Text(commitment.title)
                        .font(.body)
                        .foregroundColor(.tempoTextPrimary)

                    if let notes = commitment.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.tempoTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(commitment.scheduleLabel)
                    .font(.caption)
                    .foregroundColor(.tempoTextSecondary)
                    .multilineTextAlignment(.trailing)
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
            FixedCommitmentFormView(existingCommitment: commitment, onSave: onSave, onDelete: onDelete)
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        FixedCommitmentRowView(commitment: RoutineMockData.fixedCommitments[0])
        FixedCommitmentRowView(commitment: RoutineMockData.fixedCommitments[1])
    }
    .padding()
    .background(Color.tempoBackground)
}
