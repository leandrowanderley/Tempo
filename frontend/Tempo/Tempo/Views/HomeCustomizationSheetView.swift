//
//  HomeCustomizationSheetView.swift
//  Tempo
//
//  Sheet aberto pelo botão de ajustes na Home (TopActionsBarView): liga/desliga
//  quais seções aparecem, persistido via HomePreferencesStore.
//

import SwiftUI

struct HomeCustomizationSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var preferences = HomePreferencesStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                Text("Escolha o que aparece na tela inicial.")
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)

                VStack(spacing: 10) {
                    ForEach(HomeSection.defaultOrder) { section in
                        sectionRow(section)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        SheetHeaderView(
            title: "Personalizar Início",
            onCancel: { dismiss() },
            onConfirm: { dismiss() }
        )
    }

    private func sectionRow(_ section: HomeSection) -> some View {
        Toggle(isOn: binding(for: section)) {
            HStack(spacing: 10) {
                Image(systemName: section.sfSymbol)
                    .foregroundColor(.tempoPrimary)
                    .frame(width: 20)

                Text(section.title)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)
            }
        }
        .tint(.tempoPrimary)
        .padding(12)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func binding(for section: HomeSection) -> Binding<Bool> {
        Binding(
            get: { preferences.isEnabled(section) },
            set: { preferences.setEnabled(section, $0) }
        )
    }
}

#Preview {
    HomeCustomizationSheetView()
}
