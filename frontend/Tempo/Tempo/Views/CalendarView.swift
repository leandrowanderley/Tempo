//
//  CalendarView.swift
//  Tempo
//

import SwiftUI

// TODO: Implementar grid mensal + linha do tempo semanal (project.md §3.3). Layout placeholder por enquanto.
struct CalendarView: View {
    var body: some View {
        ScrollView {
            placeholder
                .padding(.horizontal, 20)
                .padding(.top, ScrollEdgeFadeOverlay.height)
                .padding(.bottom, Layout.tabBarClearance)
        }
        .overlay(alignment: .top) {
            ScrollEdgeFadeOverlay()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .background(Color.tempoBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Calendário")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(.tempoTextSecondary)

            Text("Calendário em construção")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text("Em breve: visão mensal em grade e linha do tempo semanal dos seus compromissos.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CalendarView()
        .environmentObject(AuthViewModel())
}
