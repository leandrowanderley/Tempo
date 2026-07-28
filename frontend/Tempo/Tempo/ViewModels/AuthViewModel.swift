//
//  AuthViewModel.swift
//  Tempo
//

import Combine
import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    // Usuário mock enquanto o login (Supabase) está desligado (ver ContentView) — dá pra
    // navegar o app inteiro (Home, Perfil, etc.) sem precisar de backend/sessão real.
    // Só nome, data de nascimento e ícone são usados por enquanto (e-mail, redefinir
    // senha, integrações e logout estão comentados no ProfileView). `restoreSession`/
    // `login`/`signUp` sobrescrevem esses valores normalmente quando a autenticação
    // voltar a ser usada.
    @Published var isAuthenticated = true
    @Published var currentUserName = "Leandro"
    @Published var currentUserEmail = ""
    @Published var currentUserIcon: String? = "icon_1"
    @Published var currentUserBirthDate: Date? = AuthViewModel.mockBirthDate
    @Published var isLoading = false
    @Published var errorMessage: String?

    private static let mockBirthDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2000, month: 1, day: 1))

    private let auth = SupabaseService.client.auth

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    /// Restaura a sessão persistida (Keychain) ao abrir o app, sem exigir login de novo.
    func restoreSession() async {
        guard let session = try? await auth.session else { return }
        currentUserName = session.user.userMetadata["name"]?.stringValue ?? session.user.email ?? ""
        currentUserEmail = session.user.email ?? ""
        currentUserIcon = session.user.userMetadata["icon"]?.stringValue
        currentUserBirthDate = (session.user.userMetadata["birthDate"]?.stringValue).flatMap { Self.birthDateFormatter.date(from: $0) }
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
            currentUserEmail = auth.currentSession?.user.email ?? email
            currentUserIcon = auth.currentSession?.user.userMetadata["icon"]?.stringValue
            currentUserBirthDate = (auth.currentSession?.user.userMetadata["birthDate"]?.stringValue).flatMap { Self.birthDateFormatter.date(from: $0) }
            isAuthenticated = true
        } catch {
            print("⚠️ Supabase signIn falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível entrar. Verifique sua conexão."
        }
    }

    func signUp(name: String, email: String, password: String, icon: String?) async {
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
            var metadata: [String: AnyJSON] = ["name": .string(name)]
            if let icon {
                metadata["icon"] = .string(icon)
            }

            try await auth.signUp(email: email, password: password, data: metadata)
            currentUserName = name
            currentUserEmail = email
            currentUserIcon = icon
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
            currentUserEmail = ""
            currentUserIcon = nil
            currentUserBirthDate = nil
        } catch {
            print("⚠️ Supabase signOut falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível sair. Verifique sua conexão."
        }
    }

    /// Troca o ícone de perfil (guardado como string, o nome do asset — ver ProfileIconCatalog).
    /// Grava só localmente no usuário mock por enquanto — sem sessão Supabase real, a chamada
    /// pro backend falharia com "sessionMissing" (ver AuthViewModel topo do arquivo).
    func updateIcon(_ icon: String) async {
        errorMessage = nil
        currentUserIcon = icon
    }

    func updateProfile(name: String, birthDate: Date?) async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "O nome não pode ficar vazio."
            return
        }

        errorMessage = nil
        currentUserName = trimmedName
        currentUserBirthDate = birthDate
    }

    func sendPasswordReset() async {
        errorMessage = nil

        guard !currentUserEmail.isEmpty else {
            errorMessage = "E-mail não encontrado."
            return
        }

        do {
            try await auth.resetPasswordForEmail(currentUserEmail)
        } catch {
            print("⚠️ Supabase resetPasswordForEmail falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível enviar o e-mail de redefinição."
        }
    }
}
