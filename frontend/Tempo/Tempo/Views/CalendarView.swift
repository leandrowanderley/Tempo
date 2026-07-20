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

    // Cache de `timelineItems`: a versão anterior era um `var` computado que refazia o
    // pipeline inteiro (~12 mil chamadas de Calendar) a cada reavaliação do `body` — inclusive
    // durante o `withAnimation` do toggle de view mode, que reavalia o body a cada frame da
    // animação, e mesmo quando `viewMode == .grid` (onde o valor nem é usado). Agora só
    // recalcula quando `filters`/`dates` de fato mudam, e adia o recálculo se a timeline não
    // estiver visível no momento da mudança.
    @State private var timelineItems: [CalendarTimelineItem] = []
    @State private var needsTimelineRefresh = true

    private static let periodLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "LLLL"
        return formatter
    }()

    var body: some View {
        CalendarContentView(viewMode: viewMode, dates: dates, timelineItems: timelineItems)
            .safeAreaInset(edge: .top, spacing: 0) {
                header
            }
            .background(Color.tempoBackground.ignoresSafeArea())
            .sheet(isPresented: $isShowingFilters) {
                CalendarFilterView(filters: $filters)
            }
            .onAppear(perform: refreshTimelineItemsIfNeeded)
            .onChange(of: viewMode) { _, newValue in
                if newValue == .timeline {
                    refreshTimelineItemsIfNeeded()
                }
            }
            .onChange(of: filters) { _, _ in
                needsTimelineRefresh = true
                if viewMode == .timeline {
                    refreshTimelineItemsIfNeeded()
                }
            }
    }

    private func refreshTimelineItemsIfNeeded() {
        guard needsTimelineRefresh else { return }

        var allItems = CalendarMockData.events(for: dates)

        if filters.showRoutines {
            allItems += CalendarMockData.routineItems(for: dates)
        }
        if filters.showFixedCommitments {
            allItems += CalendarMockData.fixedCommitmentItems(for: dates)
        }

        timelineItems = allItems.filter { item in
            (!item.isTask || filters.showTasks) && filters.selectedCategories.contains(item.category)
        }
        needsTimelineRefresh = false
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
        Self.periodLabelFormatter.string(from: Date()).capitalized
    }
}

// Isolado num View próprio para que a troca de `viewMode` reconstrua só este
// subtree. Quando o `switch` ficava direto no body do `CalendarView` (conteúdo
// raiz da aba no TabView), a mudança de identidade do subtree fazia o
// UITabBarController resetar a seleção pra primeira aba (Home) por um frame.
private struct CalendarContentView: View {
    let viewMode: CalendarViewMode
    let dates: [Date]
    let timelineItems: [CalendarTimelineItem]

    var body: some View {
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
