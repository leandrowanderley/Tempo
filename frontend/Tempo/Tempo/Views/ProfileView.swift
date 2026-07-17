//
//  ProfileView.swift
//  Tempo
//
//  Perfil & Integrações (project.md §3.7). Dados pessoais vêm da sessão Supabase —
//  User.swift/APIService.fetchProfile ainda não estão plugados aqui (TODO). Strava e
//  Apple Health ficam só como status estático: integração real está fora do escopo
//  do MVP semana 1 (ver FRONTEND_SPECS.md).
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var name = ""
    @State private var birthDate = Date()
    @State private var originalName = ""
    @State private var originalBirthDate = Date()
    @State private var isShowingIconPicker = false
    @State private var isShowingDiscardConfirmation = false
    @State private var passwordResetMessage: String?

    private var isNameDirty: Bool { name != originalName }
    private var isBirthDateDirty: Bool { !Calendar.current.isDate(birthDate, inSameDayAs: originalBirthDate) }
    private var hasUnsavedChanges: Bool { isNameDirty || isBirthDateDirty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                avatarSection
                personalInfoCard
                saveProfileButton
                resetPasswordButton

                if let passwordResetMessage {
                    Text(passwordResetMessage)
                        .font(.footnote)
                        .foregroundColor(.tempoTextSecondary)
                }

                integrationsSection
                signOutButton
            }
            .padding(20)
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(hasUnsavedChanges)
        .onAppear {
            name = authViewModel.currentUserName
            birthDate = authViewModel.currentUserBirthDate ?? Date()
            originalName = name
            originalBirthDate = birthDate
        }
        .sheet(isPresented: $isShowingIconPicker) {
            IconPickerSheetView(selectedIcon: authViewModel.currentUserIcon) { newIcon in
                Task { await authViewModel.updateIcon(newIcon) }
            }
        }
        .confirmationDialog(
            "Você tem alterações não salvas",
            isPresented: $isShowingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Descartar Alterações", role: .destructive) {
                dismiss()
            }
            Button("Continuar Editando", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack {
            Text("Perfil")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            Button {
                if hasUnsavedChanges {
                    isShowingDiscardConfirmation = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.tempoTextPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.tempoCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            avatarImage
                .frame(width: 88, height: 88)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))

            if !ProfileIconCatalog.available.isEmpty {
                Button {
                    isShowingIconPicker = true
                } label: {
                    Text("Alterar Ícone")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.tempoPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let icon = authViewModel.currentUserIcon {
            Image(icon)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.tempoDisabled)
        }
    }

    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            labeledField("Nome", isDirty: isNameDirty) {
                TempoTextField(title: "Nome", text: $name)
            }

            labeledField("Data de Nascimento", isDirty: isBirthDateDirty) {
                DatePicker("", selection: $birthDate, displayedComponents: [.date])
                    .labelsHidden()
            }

            labeledField("E-mail") {
                Text(authViewModel.currentUserEmail)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)
            }
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func labeledField(_ label: String, isDirty: Bool = false, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)
                if isDirty {
                    changeMarker
                }
            }

            content()
        }
    }

    private var changeMarker: some View {
        Text("*")
            .font(.body.weight(.bold))
            .foregroundColor(.tempoPrimary)
    }

    private var saveProfileButton: some View {
        Button {
            Task {
                await authViewModel.updateProfile(name: name, birthDate: birthDate)
                if authViewModel.errorMessage == nil {
                    originalName = name
                    originalBirthDate = birthDate
                }
            }
        } label: {
            HStack {
                Spacer()
                if authViewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Salvar Alterações")
                        .font(.body.weight(.semibold))
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.tempoPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(authViewModel.isLoading)
    }

    private var resetPasswordButton: some View {
        Button {
            Task {
                await authViewModel.sendPasswordReset()
                passwordResetMessage = authViewModel.errorMessage ?? "Enviamos um e-mail para redefinir sua senha."
            }
        } label: {
            HStack {
                Spacer()
                Text("Redefinir Senha")
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundColor(.tempoPrimary)
            .padding()
            .background(Color.tempoCard)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tempoPrimary, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var integrationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Integrações")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            integrationRow(icon: "figure.run", color: .tempoStrava, title: "Strava", isConnected: false)
            integrationRow(icon: "heart.fill", color: .tempoHealth, title: "Apple Health", isConnected: false)
        }
    }

    private func integrationRow(icon: String, color: Color, title: String, isConnected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)
                Text(isConnected ? "Conectado" : "Não conectado")
                    .font(.caption)
                    .foregroundColor(.tempoTextSecondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var signOutButton: some View {
        Button {
            Task {
                await authViewModel.logout()
                dismiss()
            }
        } label: {
            HStack {
                Spacer()
                Text("Sair da Conta")
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundColor(.tempoDestructive)
            .padding()
            .background(Color.tempoCard)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tempoDestructive, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
