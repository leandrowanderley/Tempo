//
//  MainTabView.swift
//  Tempo
//
//  TabView de navegação inferior com as 3 abas estruturais (project.md §3).
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CalendarView()
                .tabItem {
                    Label("Calendário", systemImage: "calendar")
                }

            RoutinePlannerView()
                .tabItem {
                    Label("Rotina", systemImage: "target")
                }
        }
        .tint(.tempoPrimary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
