//
//  DailyQuoteWidgetView.swift
//  Tempo
//
//  Card com frase motivacional na Home, troca 1x por dia (determinístico pelo dia
//  do ano — mesma frase o dia inteiro, sem precisar guardar estado).
//

import SwiftUI

struct DailyQuoteWidgetView: View {
    private static let quotes: [String] = [
        "Pequenos passos todos os dias constroem grandes resultados.",
        "Você não precisa ser perfeito, só precisa continuar.",
        "Foco no progresso, não na perfeição.",
        "Cada tarefa concluída é uma vitória.",
        "Disciplina é escolher entre o que você quer agora e o que você quer mais.",
        "O dia de hoje é uma nova chance de avançar.",
        "Consistência vence motivação.",
        "Comece onde você está, use o que você tem."
    ]

    private var todayQuote: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.quotes[dayOfYear % Self.quotes.count]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "quote.bubble.fill")
                .font(.title3)
                .foregroundColor(.tempoPrimary)

            Text(todayQuote)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.tempoTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tempoCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.tempoBorder, lineWidth: 1)
        )
    }
}

#Preview {
    DailyQuoteWidgetView()
        .padding()
        .background(Color.tempoBackground)
}
