//
//  CalendarView.swift
//  Tempo
//

import SwiftUI

private enum CalendarViewMode {
    case grid
    case timeline
}

// TODO: Implementar grid mensal (project.md §3.3). Timeline semanal já funcional; grid ainda é placeholder.
struct CalendarView: View {
    @State private var viewMode: CalendarViewMode = .timeline
    @State private var isShowingFilters = false
    @State private var filters = CalendarFilters.makeDefault()
    @State private var dates = CalendarMockData.dateRange()

    private var timelineItems: [CalendarTimelineItem] {
        var allItems = CalendarMockData.events(for: dates)

        if filters.showRoutines {
            allItems += CalendarMockData.routineItems(for: dates)
        }
        if filters.showFixedCommitments {
            allItems += CalendarMockData.fixedCommitmentItems(for: dates)
        }

        return allItems.filter { item in
            (!item.isTask || filters.showTasks) && filters.selectedCategories.contains(item.category)
        }
    }

    var body: some View {
        Group {
            switch viewMode {
            case .grid:
                ScrollView {
                    placeholder(
                        icon: "calendar",
                        title: "Visão mensal em construção",
                        message: "Em breve: grade do mês com a agenda do dia selecionado."
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, ScrollEdgeFadeOverlay.height)
                    .padding(.bottom, Layout.tabBarClearance)
                }
                .overlay(alignment: .top) {
                    ScrollEdgeFadeOverlay()
                }
            case .timeline:
                // Sem ScrollEdgeFadeOverlay aqui: a linha de dias da timeline já fica fixa
                // no topo (não desliza por baixo do header), então o fade não se aplica.
                WeekTimelineView(dates: dates, items: timelineItems)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .sheet(isPresented: $isShowingFilters) {
            CalendarFilterView(filters: $filters)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                viewModeToggle
                Spacer()
                TopActionsBarView()
            }

            HStack(alignment: .center) {
                Text(periodLabel)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.tempoTextPrimary)

                Spacer()

                filterButton
            }
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

    private var filterButton: some View {
        Button {
            isShowingFilters = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .semibold))
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

    private var periodLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: Date()).capitalized
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
