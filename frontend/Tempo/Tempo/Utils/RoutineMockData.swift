//
//  RoutineMockData.swift
//  Tempo
//
//  Dados estáticos pro Routine Planner (e reaproveitados pelo widget da Home). Sem rede.
//

import Foundation

enum RoutineMockData {
    static let workouts: [Routine] = [
        Routine(id: "r1", title: "Corrida", type: .workout, targetCount: 3, currentCount: 2),
        Routine(id: "r2", title: "Superior", type: .workout, targetCount: 1, currentCount: 1),
        Routine(id: "r3", title: "Inferior", type: .workout, targetCount: 2, currentCount: 0)
    ]

    static let habits: [Routine] = [
        Routine(id: "h1", title: "Meditação", type: .habit, targetCount: 5, currentCount: 2),
        Routine(id: "h2", title: "Leitura", type: .habit, targetCount: 4, currentCount: 1)
    ]

    static let fixedCommitments: [FixedCommitment] = [
        FixedCommitment(id: "f1", title: "Aula de PAA", schedule: "Seg e Qui, 09:00 - 11:00", category: "Faculdade"),
        FixedCommitment(id: "f2", title: "Edge Academy", schedule: "Ter e Qui, 19:00 - 21:00", category: "Trabalho")
    ]
}
