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
            id: "e11",
            title: "Entrega do Trabalho de PAA",
            notes: "Enviar PDF pelo portal",
            isAllDay: false,
            startDate: nil,
            endDate: Date().addingTimeInterval(10800),
            category: "Faculdade",
            isTask: true,
            completionStatus: .notDone
        ),
        Event(
            id: "e12",
            title: "Happy Hour da Firma",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(21600),
            endDate: Date().addingTimeInterval(28800),
            category: "Trabalho",
            isTask: false,
            completionStatus: .notDone
        )
    ]

    /// Eventos com data flexível (`isFlexible`): ficam em aberto por 7 dias a partir de `startDate`.
    static let flexibleEvents: [Event] = [
        Event(
            id: "e9",
            title: "Organizar o quarto",
            notes: nil,
            isAllDay: true,
            startDate: Date().addingTimeInterval(-2 * 86400),
            endDate: Date().addingTimeInterval(5 * 86400),
            category: "Habitos",
            isTask: false,
            completionStatus: .notDone,
            isFlexible: true
        ),
        Event(
            id: "e13",
            title: "Estudar para a prova de Cálculo",
            notes: nil,
            isAllDay: true,
            startDate: Date(),
            endDate: Date().addingTimeInterval(7 * 86400),
            category: "Faculdade",
            isTask: false,
            completionStatus: .notDone,
            isFlexible: true
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
            id: "e14",
            title: "Renovar carteirinha da faculdade",
            notes: nil,
            isAllDay: false,
            startDate: nil,
            endDate: nil,
            category: "Faculdade",
            isTask: true,
            completionStatus: .notDone
        )
    ]
}
