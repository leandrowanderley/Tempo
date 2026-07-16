//
//  AddCategorySheetView.swift
//  Tempo
//
//  Sheet compacto pra criar uma categoria nova a partir do EventFormView:
//  nome + cor da bolinha (CategoryDotView).
//

import SwiftUI

struct AddCategorySheetView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, Color) -> Void

    // Paleta fixa de 8 cores — mantém a bolinha consistente com o resto do design system
    // em vez de deixar o usuário escolher qualquer tom via ColorPicker nativo.
    private let paletteHex = ["FF3B30", "FF9500", "FFCC00", "34C759", "007AFF", "AF52DE", "FF2D55", "8E8E93"]

    @State private var name = ""
    @State private var selectedHex = "FF3B30"

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            TempoTextField(title: "Nome da categoria", text: $name)

            VStack(alignment: .leading, spacing: 8) {
                Text("Cor da bolinha")
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(paletteHex, id: \.self) { hex in
                        colorSwatch(hex)
                    }
                }
            }

            Spacer()
        }
        .padding(20)
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }

    private func colorSwatch(_ hex: String) -> some View {
        let isSelected = hex == selectedHex

        return Button {
            selectedHex = hex
        } label: {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(Color.tempoTextPrimary, lineWidth: isSelected ? 3 : 0)
                        .padding(-4)
                )
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        SheetHeaderView(
            title: "Nova Categoria",
            isConfirmEnabled: isFormValid,
            onCancel: { dismiss() },
            onConfirm: {
                onSave(name.trimmingCharacters(in: .whitespaces), Color(hex: selectedHex))
                dismiss()
            }
        )
    }
}

#Preview {
    AddCategorySheetView(onSave: { _, _ in })
}
