//
//  SheetHeaderView.swift
//  Tempo
//
//  Header padrão dos sheets de criação/edição: X (fecha) à esquerda, título ao centro,
//  check (confirma) à direita — usado por EventFormView, AddCategorySheetView, etc.
//

import SwiftUI

struct SheetHeaderView: View {
    let title: String
    var isConfirmEnabled: Bool = true
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack {
            circleButton(systemName: "xmark", background: .tempoCard, foreground: .tempoTextPrimary, bordered: true, action: onCancel)

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            circleButton(systemName: "checkmark", background: isConfirmEnabled ? .tempoPrimary : .tempoDisabled, foreground: .white, bordered: false, action: onConfirm)
                .disabled(!isConfirmEnabled)
        }
    }

    private func circleButton(systemName: String, background: Color, foreground: Color, bordered: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(foreground)
                .frame(width: 32, height: 32)
                .background(background)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.tempoBorder, lineWidth: bordered ? 1 : 0)
                )
        }
    }
}

#Preview {
    SheetHeaderView(title: "Novo Evento", isConfirmEnabled: true, onCancel: {}, onConfirm: {})
        .padding()
        .background(Color.tempoBackground)
}
