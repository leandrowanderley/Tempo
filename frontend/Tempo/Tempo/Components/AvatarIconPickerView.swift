//
//  AvatarIconPickerView.swift
//  Tempo
//
//  Seletor do ícone de perfil no cadastro (project.md §3.7 — dados pessoais).
//  Lista os ícones descobertos em ProfileIconCatalog (icon_1, icon_2, icon_3...).
//

import SwiftUI

struct AvatarIconPickerView: View {
    @Binding var selectedIcon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escolha um ícone")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            HStack(spacing: 16) {
                ForEach(ProfileIconCatalog.available, id: \.self) { icon in
                    iconButton(icon)
                }

                Spacer()
            }
        }
    }

    private func iconButton(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon

        return Button {
            selectedIcon = icon
        } label: {
            Image(icon)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isSelected ? Color.tempoPrimary : Color.tempoBorder, lineWidth: isSelected ? 3 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedIcon: String? = ProfileIconCatalog.available.first

    AvatarIconPickerView(selectedIcon: $selectedIcon)
        .padding()
        .background(Color.tempoBackground)
}
