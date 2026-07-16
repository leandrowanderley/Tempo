//
//  AddRoutineSheetView.swift
//  Tempo
//
//  Sheet compacto pra adicionar uma nova modalidade de treino ou hábito personalizado
//  no Routine Planner (project.md §3.4). Meta semanal começa em 1 e é ajustada depois
//  com os steppers da lista.
//

import SwiftUI

struct AddRoutineSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (String) -> Void

    @State private var name = ""

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SheetHeaderView(
                title: title,
                isConfirmEnabled: isFormValid,
                onCancel: { dismiss() },
                onConfirm: {
                    onSave(name.trimmingCharacters(in: .whitespaces))
                    dismiss()
                }
            )

            TempoTextField(title: "Nome", text: $name)

            Spacer()
        }
        .padding(20)
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    AddRoutineSheetView(title: "Novo Treino", onSave: { _ in })
}
