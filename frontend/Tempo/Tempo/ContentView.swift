//
//  ContentView.swift
//  Tempo
//
//  Created by Leandro Wanderley Quintela Tenório Cavalcante on 13/07/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        // Gate de login (Supabase) desligado temporariamente pra dev local sem backend —
        // reverter pra `if authViewModel.isAuthenticated { MainTabView() } else { AuthContainerView() }`
        // quando a autenticação voltar a ser usada.
        MainTabView()
            .task {
                await authViewModel.restoreSession()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
