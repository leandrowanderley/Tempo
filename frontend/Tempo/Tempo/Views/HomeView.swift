//
//  HomeView.swift
//  Tempo
//

import SwiftUI

// TODO: Trocar por TabView real (Home/Calendario/RoutinePlanner) quando as outras abas existirem.
struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var today = HomeMockData.today
    @State private var unscheduledTasks = HomeMockData.unscheduledTasks
    @State private var flexibleEvents = HomeMockData.flexibleEvents
    private let routines = RoutineMockData.workouts + RoutineMockData.habits
    // TODO: mockado — trocar pela sequência real assim que o back-end calcular streakWeeks (ver TODO.MD).
    private let streakWeeks = 5

    @ObservedObject private var homePreferences = HomePreferencesStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if homePreferences.isEnabled(.dailyQuote) {
                    DailyQuoteWidgetView()
                }

                if homePreferences.isEnabled(.weeklyProgress) {
                    WeeklyProgressWidgetView(
                        routines: routines,
                        streakWeeks: streakWeeks
                    )
                }

                if homePreferences.isEnabled(.quickStats) {
                    QuickStatsWidgetView(
                        todayCount: upcomingToday.count,
                        overdueCount: overdueEvents.count,
                        flexibleCount: activeFlexibleEvents.count,
                        unscheduledCount: unscheduledTasks.count
                    )
                }

                if homePreferences.isEnabled(.today) {
                    sectionList(title: "O Que Temos Hoje", events: upcomingToday)
                }
                if homePreferences.isEnabled(.overdue) {
                    sectionList(title: "Atrasados", events: overdueEvents)
                }
                if homePreferences.isEnabled(.flexible) {
                    sectionList(title: "Eventos Flexíveis", events: activeFlexibleEvents)
                }
                if homePreferences.isEnabled(.unscheduled) {
                    sectionList(title: "Sem Data", events: unscheduledTasks)
                }
            }
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Olá, \(authViewModel.currentUserName)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.tempoTextPrimary)

                Text(Date().formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                        .locale(Locale(identifier: "pt_BR"))
                ))
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)
            }

            Spacer()

            TopActionsBarView(onAddEvent: upsert)
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private var upcomingToday: [Event] {
        today.filter { !$0.hasEnded }
    }

    private var overdueEvents: [Event] {
        (today + unscheduledTasks + flexibleEvents).filter { $0.isLate }
    }

    /// Eventos flexíveis ainda dentro da janela de 7 dias desde a criação.
    private var activeFlexibleEvents: [Event] {
        flexibleEvents.filter { !$0.hasEnded }
    }

    @ViewBuilder
    private func sectionList(title: String, events: [Event]) -> some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)

                VStack(spacing: 10) {
                    ForEach(events) { event in
                        EventCardView(event: event, onSave: upsert, onStatusChange: { setStatus($0, for: event) }, onDelete: delete)
                    }
                }
            }
        }
    }

    /// Cria ou edita: remove o evento (por id) de onde estiver e o reinsere na
    /// lista correta, já que criar/editar pode mudar de categoria (ex.: virar flexível).
    private func upsert(_ event: Event) {
        today.removeAll { $0.id == event.id }
        unscheduledTasks.removeAll { $0.id == event.id }
        flexibleEvents.removeAll { $0.id == event.id }

        if event.isFlexible {
            flexibleEvents.append(event)
        } else if event.isTask && event.endDate == nil {
            unscheduledTasks.append(event)
        } else {
            today.append(event)
        }
    }

    private func delete(_ event: Event) {
        today.removeAll { $0.id == event.id }
        unscheduledTasks.removeAll { $0.id == event.id }
        flexibleEvents.removeAll { $0.id == event.id }
    }

    private func setStatus(_ status: EventCompletionStatus, for event: Event) {
        if let index = today.firstIndex(where: { $0.id == event.id }) {
            today[index].completionStatus = status
        } else if let index = unscheduledTasks.firstIndex(where: { $0.id == event.id }) {
            unscheduledTasks[index].completionStatus = status
        } else if let index = flexibleEvents.firstIndex(where: { $0.id == event.id }) {
            flexibleEvents[index].completionStatus = status
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
