//
//  TopActionsBarView.swift
//  Tempo
//

import SwiftUI

struct TopActionsBarView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isShowingProfile = false
    @State private var isShowingEventForm = false
    @State private var isShowingHomeCustomization = false
    @State private var isShowingSearch = false

    var onAddEvent: (Event) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 18) {
            actionButton(systemName: "plus") { isShowingEventForm = true }
            actionButton(systemName: "magnifyingglass") { isShowingSearch = true }
            actionButton(systemName: "slider.horizontal.3") { isShowingHomeCustomization = true }
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
        .sheet(isPresented: $isShowingHomeCustomization) {
            HomeCustomizationSheetView()
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchSheetView()
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
