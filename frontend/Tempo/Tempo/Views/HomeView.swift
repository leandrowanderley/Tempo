//
//  HomeView.swift
//  Tempo
//

import SwiftUI

// TODO: Trocar por TabView real (Home/Calendario/RoutinePlanner) quando as outras abas existirem.
struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var today = HomeMockData.today
    @State private var tomorrow = HomeMockData.tomorrow
    @State private var unscheduledTasks = HomeMockData.unscheduledTasks
    private let routines = RoutineMockData.workouts + RoutineMockData.habits

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                WeeklyProgressWidgetView(
                    routines: routines,
                    motivationalMessage: "You're doing great!"
                )

                sectionList(title: "O Que Temos Hoje", events: today)
                sectionList(title: "Amanhã", events: tomorrow)
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

                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)
            }

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
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
                        EventCardView(event: event, onToggleDone: { toggleDone(for: event) })
                    }
                }
            }
        }
    }

    private func toggleDone(for event: Event) {
        if let index = today.firstIndex(where: { $0.id == event.id }) {
            today[index].isDone.toggle()
        } else if let index = tomorrow.firstIndex(where: { $0.id == event.id }) {
            tomorrow[index].isDone.toggle()
        } else if let index = unscheduledTasks.firstIndex(where: { $0.id == event.id }) {
            unscheduledTasks[index].isDone.toggle()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
