//
//  HomeView.swift
//  Tempo
//

import SwiftUI

// TODO: Trocar por TabView real (Home/Calendario/RoutinePlanner) quando as outras abas existirem.
struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    private let today = HomeMockData.today
    private let tomorrow = HomeMockData.tomorrow
    private let unscheduledTasks = HomeMockData.unscheduledTasks
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
                        EventCardView(event: event)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
