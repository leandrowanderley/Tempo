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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                WeeklyProgressWidgetView(
                    routines: routines,
                    streakWeeks: streakWeeks
                )

                sectionList(title: "O Que Temos Hoje", events: upcomingToday)
                sectionList(title: "Atrasados", events: overdueEvents)
                sectionList(title: "Eventos Flexíveis", events: activeFlexibleEvents)
                sectionList(title: "Sem Data", events: unscheduledTasks)
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

            TopActionsBarView()
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
                        EventCardView(event: event, onStatusChange: { setStatus($0, for: event) })
                    }
                }
            }
        }
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
