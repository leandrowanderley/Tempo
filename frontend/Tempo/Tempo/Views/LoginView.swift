//
//  LoginView.swift
//  Tempo
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool

    @State private var email = ""
    @State private var password = ""

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    private var switchToSignUpText: AttributedString {
        var cadastreSe = AttributedString("Cadastre-se")
        cadastreSe.foregroundColor = .tempoPrimary
        cadastreSe.font = .footnote.bold()
        return AttributedString("Não tem conta? ") + cadastreSe
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Tempo")
                    .font(.largeTitle.bold())
                    .foregroundColor(.tempoTextPrimary)
                Text("Entre para continuar")
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)
            }
            .padding(.top, 48)

            VStack(spacing: 16) {
                TempoTextField(title: "E-mail", text: $email, keyboardType: .emailAddress)
                TempoTextField(title: "Senha", text: $password, isSecure: true)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.tempoDestructive)
            }

            Button {
                Task { await authViewModel.login(email: email, password: password) }
            } label: {
                Group {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Entrar")
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
                isShowingSignUp = true
            } label: {
                Text(switchToSignUpText)
            }
            .font(.footnote)
            .foregroundColor(.tempoTextSecondary)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    LoginView(isShowingSignUp: .constant(false))
        .environmentObject(AuthViewModel())
}
