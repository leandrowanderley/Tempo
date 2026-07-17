//
//  IconPickerSheetView.swift
//  Tempo
//
//  Sheet de troca de ícone de perfil, aberta a partir do "Alterar Ícone" no
//  ProfileView. Lista em grade todos os ícones descobertos em ProfileIconCatalog
//  (icon_1, icon_2, icon_3...) — tocar em um já aplica e fecha.
//

import SwiftUI

struct IconPickerSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let selectedIcon: String?
    let onSelect: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 16)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ProfileIconCatalog.available, id: \.self) { icon in
                        iconButton(icon)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack {
            Text("Alterar Ícone")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.tempoTextPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.tempoCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))
            }
        }
    }

    private func iconButton(_ icon: String) -> some View {
        let isSelected = icon == selectedIcon

        return Button {
            onSelect(icon)
            dismiss()
        } label: {
            Image(icon)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isSelected ? Color.tempoPrimary : Color.tempoBorder, lineWidth: isSelected ? 3 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IconPickerSheetView(selectedIcon: ProfileIconCatalog.available.first, onSelect: { _ in })
}
