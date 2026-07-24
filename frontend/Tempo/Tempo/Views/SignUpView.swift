//
//  SignUpView.swift
//  Tempo
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedIcon: String? = ProfileIconCatalog.available.first

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    private var switchToLoginText: AttributedString {
        var entrar = AttributedString("Entrar")
        entrar.foregroundColor = .tempoPrimary
        entrar.font = .footnote.bold()
        return AttributedString("Já tem conta? ") + entrar
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Criar conta")
                        .font(.largeTitle.bold())
                        .foregroundColor(.tempoTextPrimary)
                    Text("Comece a organizar seu tempo")
                        .font(.subheadline)
                        .foregroundColor(.tempoTextSecondary)
                }
                .padding(.top, 48)

                if !ProfileIconCatalog.available.isEmpty {
                    AvatarIconPickerView(selectedIcon: $selectedIcon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 16) {
                    TempoTextField(title: "Nome", text: $name)
                    TempoTextField(title: "E-mail", text: $email, keyboardType: .emailAddress)
                    TempoTextField(title: "Senha", text: $password, isSecure: true)
                }

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.tempoDestructive)
                }

                Button {
                    Task { await authViewModel.signUp(name: name, email: email, password: password, icon: selectedIcon) }
                } label: {
                    Group {
                        if authViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Cadastrar")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.tempoPrimary : Color.tempoDisabled)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isFormValid || authViewModel.isLoading)

                Button {
                    authViewModel.errorMessage = nil
                    isShowingSignUp = false
                } label: {
                    Text(switchToLoginText)
                }
                .font(.footnote)
                .foregroundColor(.tempoTextSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    SignUpView(isShowingSignUp: .constant(true))
        .environmentObject(AuthViewModel())
}
