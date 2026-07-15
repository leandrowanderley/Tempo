//
//  HomeMockData.swift
//  Tempo
//
//  Dados estáticos apenas para validação do layout da Home. Sem chamadas de rede.
//

import Foundation

enum HomeMockData {
    static let routines: [Routine] = [
        Routine(id: "r1", title: "Corrida", type: .workout, targetCount: 3, currentCount: 2),
        Routine(id: "r2", title: "Superior", type: .workout, targetCount: 1, currentCount: 1),
        Routine(id: "r3", title: "Meditação", type: .habit, targetCount: 5, currentCount: 2)
    ]

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
            isDone: false
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
            isDone: false
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
            isDone: false
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
            isDone: false
        )
    ]

    static let tomorrow: [Event] = [
        Event(
            id: "e5",
            title: "Aula de PAA",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(86400 + 32400),
            endDate: Date().addingTimeInterval(86400 + 39600),
            category: "Faculdade",
            isTask: false,
            isDone: false
        ),
        Event(
            id: "e6",
            title: "Treino de Inferior",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(86400 + 61200),
            endDate: Date().addingTimeInterval(86400 + 64800),
            category: "Treinos",
            isTask: false,
            isDone: false
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
            isDone: false
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
            isDone: false
        )
    ]
}
