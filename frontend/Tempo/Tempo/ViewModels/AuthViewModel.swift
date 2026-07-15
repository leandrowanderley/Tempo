//
//  AuthViewModel.swift
//  Tempo
//

import Combine
import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth = SupabaseService.client.auth

    /// Restaura a sessão persistida (Keychain) ao abrir o app, sem exigir login de novo.
    func restoreSession() async {
        guard let session = try? await auth.session else { return }
        currentUserName = session.user.userMetadata["name"]?.stringValue ?? session.user.email ?? ""
        isAuthenticated = true
    }

    func login(email: String, password: String) async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.isEmpty else {
            errorMessage = "Preencha e-mail e senha."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await auth.signIn(email: email, password: password)
            let fallbackName = email.components(separatedBy: "@").first ?? email
            currentUserName = auth.currentSession?.user.userMetadata["name"]?.stringValue ?? fallbackName
            isAuthenticated = true
        } catch {
            print("⚠️ Supabase signIn falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível entrar. Verifique sua conexão."
        }
    }

    func signUp(name: String, email: String, password: String) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Preencha todos os campos."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await auth.signUp(email: email, password: password, data: ["name": .string(name)])
            currentUserName = name
            isAuthenticated = true
        } catch {
            print("⚠️ Supabase signUp falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível criar a conta. Verifique sua conexão."
        }
    }

    func logout() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await auth.signOut()
            isAuthenticated = false
            currentUserName = ""
        } catch {
            print("⚠️ Supabase signOut falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível sair. Verifique sua conexão."
        }
    }
}
