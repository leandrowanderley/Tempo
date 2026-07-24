//
//  HomeMockData.swift
//  Tempo
//
//  Dados estáticos apenas para validação do layout da Home. Sem chamadas de rede.
//

import Foundation

enum HomeMockData {
    static let today: [Event] = [
        Event(
            id: "e1",
            title: "Aula de PAA",
            notes: "Sala 204",
            isAllDay: false,
            startDate: Date().addingTimeInterval(-7200),
            endDate: Date().addingTimeInterval(-3600),
            category: "Faculdade",
            isTask: false,
            completionStatus: .notDone
        ),
        Event(
            id: "e2",
            title: "Treino de Corrida",
            notes: "5km leve",
            isAllDay: false,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date().addingTimeInterval(1800),
            category: "Treinos",
            isTask: false,
            completionStatus: .notDone
        ),
        Event(
            id: "e3",
            title: "Reunião Edge Academy",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(5400),
            endDate: Date().addingTimeInterval(9000),
            category: "Trabalho",
            isTask: false,
            completionStatus: .notDone
        ),
        Event(
            id: "e4",
            title: "Meditação",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(12600),
            endDate: Date().addingTimeInterval(13500),
            category: "Habitos",
            isTask: false,
            completionStatus: .notDone
        )
    ]

    static let unscheduledTasks: [Event] = [
        Event(
            id: "e7",
            title: "Comprar material de estudo",
            notes: nil,
            isAllDay: false,
            startDate: nil,
            endDate: nil,
            category: "Faculdade",
            isTask: true,
            completionStatus: .notDone
        ),
        Event(
            id: "e8",
            title: "Ligar para o dentista",
            notes: nil,
            isAllDay: false,
            startDate: nil,
            endDate: nil,
            category: "Trabalho",
            isTask: true,
            completionStatus: .notDone
        )
    ]
}
