//
//  HabitStreak.swift
//  Tempo
//
//  Frases motivacionais pro foguinho de sequência semanal de hábitos (ver TODO.MD
//  pra regra de negócio completa de como a sequência sobe/zera).
//

import Foundation

enum HabitStreakMessages {
    private static let milestones: [(weeks: Int, phrases: [String])] = [
        (0, [
            "Comece sua sequência essa semana!",
            "Toda jornada começa com a primeira semana.",
            "Vamos acender esse balão?"
        ]),
        (1, [
            "Primeira semana! Continue assim.",
            "semana de sequência, o começo é sempre o mais difícil.",
            "Você deu o primeiro passo, não pare agora."
        ]),
        (5, [
            "semanas seguidas! Isso já é hábito.",
            "Mais de um mês de consistência. Muito bom!",
            "semanas, sua rotina está pegando forma."
        ]),
        (10, [
            "semanas de sequência! Impressionante.",
            "Mais de 2 meses de consistência. Continue.",
            "semanas, você já é referência de disciplina."
        ]),
        (30, [
            "semanas! Quase 7 meses sem falhar.",
            "semanas de sequência, você está imparável.",
            "semanas seguidas. Poucos chegam até aqui."
        ]),
        (50, [
            "semanas! Quase 1 ano de consistência total.",
            "semanas de sequeência, nível lendário.",
            "semanas seguidas. Você redefiniu sua rotina."
        ]),
        (100, [
            "semanas! Quase 2 anos sem perder uma única semana.",
            "semanas de sequência, você é imparável.",
            "semanas seguidas. Isso é maestria."
        ])
    ]

    static func message(forWeeks weeks: Int) -> String {
        let milestone = milestones.last(where: { $0.weeks <= weeks }) ?? milestones[0]
        return milestone.phrases.randomElement() ?? milestone.phrases[0]
    }
}
