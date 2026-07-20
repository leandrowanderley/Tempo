//
//  MainTabView.swift
//  Tempo
//
//  TabView de navegação inferior com as 3 abas estruturais (project.md §3).
//

import SwiftUI

struct MainTabView: View {
    // Sem `selection:` explícito, o TabView usa índice posicional interno do
    // UITabBarController: uma mudança de estado animada (withAnimation) no
    // conteúdo da aba visível podia fazer a seleção resetar pra Home por um
    // frame (bug conhecido do SwiftUI). Um binding explícito com `.tag`
    // elimina essa dependência do estado interno do UIKit.
    private enum Tab {
        case home, calendar, routine
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            CalendarView()
                .tabItem {
                    Label("Calendário", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            RoutinePlannerView()
                .tabItem {
                    Label("Rotina", systemImage: "target")
                }
                .tag(Tab.routine)
        }
        .tint(.tempoPrimary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
