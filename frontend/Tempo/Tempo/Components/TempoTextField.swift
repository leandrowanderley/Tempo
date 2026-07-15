//
//  TempoTextField.swift
//  Tempo
//

import SwiftUI

struct TempoTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
