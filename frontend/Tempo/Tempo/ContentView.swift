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
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthContainerView()
            }
        }
        .task {
            await authViewModel.restoreSession()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
