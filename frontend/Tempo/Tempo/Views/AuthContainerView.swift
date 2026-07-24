//
//  AuthContainerView.swift
//  Tempo
//

import SwiftUI

struct AuthContainerView: View {
    @State private var isShowingSignUp = false

    var body: some View {
        ZStack {
            Color.tempoBackground.ignoresSafeArea()

            if isShowingSignUp {
                SignUpView(isShowingSignUp: $isShowingSignUp)
            } else {
                LoginView(isShowingSignUp: $isShowingSignUp)
            }
        }
        .animation(.default, value: isShowingSignUp)
    }
}

#Preview {
    AuthContainerView()
        .environmentObject(AuthViewModel())
}
