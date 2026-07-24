//
//  TempoApp.swift
//  Tempo
//
//  Created by Leandro Wanderley Quintela Tenório Cavalcante on 13/07/26.
//

import SwiftUI

@main
struct TempoApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
