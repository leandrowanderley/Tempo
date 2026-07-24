//
//  SupabaseService.swift
//  Tempo
//

import Foundation
import Supabase

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Secrets.supabaseURL)!,
        supabaseKey: Secrets.supabaseAnonKey,
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
