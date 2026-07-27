//
//  TopActionsBarView.swift
//  Tempo
//

import SwiftUI

struct TopActionsBarView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isShowingProfile = false
    @State private var isShowingEventForm = false

    // TODO: Ligar onSearch quando a Central de Busca existir (project.md §3.6).
    var onSearch: () -> Void = {}
    var onAddEvent: (Event) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 18) {
            actionButton(systemName: "plus") { isShowingEventForm = true }
            actionButton(systemName: "magnifyingglass", action: onSearch)
            Button {
                isShowingProfile = true
            } label: {
                profileIcon
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.tempoCard)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.tempoBorder, lineWidth: 1)
        )
        .sheet(isPresented: $isShowingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $isShowingEventForm) {
            EventFormView(onSave: onAddEvent)
        }
    }

    private func actionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.tempoPrimary)
        }
    }

    @ViewBuilder
    private var profileIcon: some View {
        if let icon = authViewModel.currentUserIcon {
            Image(icon)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle")
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
