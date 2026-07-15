//
//  TopActionsBarView.swift
//  Tempo
//

import SwiftUI

struct TopActionsBarView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showAccountActions = false
    @State private var isShowingEventForm = false

    // TODO: Ligar onSearch quando a Central de Busca existir (project.md §3.6).
    var onSearch: () -> Void = {}

    var body: some View {
        HStack(spacing: 18) {
            actionButton(systemName: "plus") { isShowingEventForm = true }
            actionButton(systemName: "magnifyingglass", action: onSearch)
            actionButton(systemName: "person.circle") { showAccountActions = true }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.tempoCard)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.tempoBorder, lineWidth: 1)
        )
        .confirmationDialog("Conta", isPresented: $showAccountActions, titleVisibility: .visible) {
            Button("Sair da conta", role: .destructive) {
                Task { await authViewModel.logout() }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingEventForm) {
            EventFormView()
        }
    }

    private func actionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.tempoPrimary)
        }
    }
}

#Preview {
    TopActionsBarView()
        .padding()
        .background(Color.tempoBackground)
        .environmentObject(AuthViewModel())
}
