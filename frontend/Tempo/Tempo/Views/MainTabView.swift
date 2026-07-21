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

// Calendário está sendo refeito do zero — placeholder até a nova implementação.
private struct CalendarPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(.tempoTextSecondary)

            Text("Calendário em construção")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text("Estamos refazendo essa tela. Volte em breve.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tempoBackground.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
