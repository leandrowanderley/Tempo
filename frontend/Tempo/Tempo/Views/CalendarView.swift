//
//  CalendarView.swift
//  Tempo
//

import SwiftUI

private enum CalendarViewMode: String, CaseIterable {
    case grid
    case timeline
}

// TODO: Implementar grid mensal + linha do tempo semanal (project.md §3.3). Conteúdo de cada visão ainda é placeholder.
struct CalendarView: View {
    @State private var viewMode: CalendarViewMode = .grid

    var body: some View {
        ScrollView {
            content
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
        HStack(alignment: .center, spacing: 12) {
            viewModeToggle

            Text("Calendário")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private var viewModeToggle: some View {
        Button {
            withAnimation(.easeInOut) {
                viewMode = viewMode == .grid ? .timeline : .grid
            }
        } label: {
            Image(systemName: viewMode == .grid ? "rectangle.grid.3x2" : "rectangle.grid.1x2")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.tempoTextPrimary)
                .frame(width: 36, height: 36)
                .background(Color.tempoCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.tempoBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewMode {
        case .grid:
            placeholder(
                icon: "calendar",
                title: "Visão mensal em construção",
                message: "Em breve: grade do mês com a agenda do dia selecionado."
            )
        case .timeline:
            placeholder(
                icon: "clock",
                title: "Linha do tempo em construção",
                message: "Em breve: colunas por dia com os horários de 01h às 24h."
            )
        }
    }

    private func placeholder(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.tempoTextSecondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text(message)
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
