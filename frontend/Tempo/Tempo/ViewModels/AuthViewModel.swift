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
    @Published var currentUserEmail = ""
    @Published var currentUserIcon: String?
    @Published var currentUserBirthDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

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

    /// user_metadata é substituído por inteiro na API do Supabase a cada update, então todo
    /// update reenvia os três campos juntos pra não perder os que não mudaram.
    private func metadata(name: String, icon: String?, birthDate: Date?) -> [String: AnyJSON] {
        var data: [String: AnyJSON] = ["name": .string(name)]
        if let icon {
            data["icon"] = .string(icon)
        }
        if let birthDate {
            data["birthDate"] = .string(Self.birthDateFormatter.string(from: birthDate))
        }
        return data
    }

    /// Troca o ícone de perfil (guardado como string, o nome do asset — ver ProfileIconCatalog).
    func updateIcon(_ icon: String) async {
        errorMessage = nil

        do {
            let updatedUser = try await auth.update(
                user: UserAttributes(data: metadata(name: currentUserName, icon: icon, birthDate: currentUserBirthDate))
            )
            currentUserIcon = updatedUser.userMetadata["icon"]?.stringValue ?? icon
        } catch {
            print("⚠️ Supabase update (icon) falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível atualizar o ícone."
        }
    }

    func updateProfile(name: String, birthDate: Date?) async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "O nome não pode ficar vazio."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let updatedUser = try await auth.update(
                user: UserAttributes(data: metadata(name: trimmedName, icon: currentUserIcon, birthDate: birthDate))
            )
            currentUserName = updatedUser.userMetadata["name"]?.stringValue ?? trimmedName
            currentUserBirthDate = (updatedUser.userMetadata["birthDate"]?.stringValue).flatMap { Self.birthDateFormatter.date(from: $0) }
        } catch {
            print("⚠️ Supabase update (profile) falhou:", error)
            errorMessage = (error as? AuthError)?.message ?? "Não foi possível atualizar o perfil."
        }
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
