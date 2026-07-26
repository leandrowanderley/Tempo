//
//  RoutineMockData.swift
//  Tempo
//
//  Dados estáticos pro Routine Planner (e reaproveitados pelo widget da Home). Sem rede.
//

import Foundation

enum RoutineMockData {
    static let workouts: [Routine] = [
        Routine(
            id: "r1",
            title: "Corrida",
            type: .workout,
            targetCount: 3,
            currentCount: 2,
            occurrences: [
                occurrence(.monday, 7, 8),
                occurrence(.wednesday, 7, 8),
                occurrence(.friday, 7, 8)
            ]
        ),
        Routine(
            id: "r2",
            title: "Superior",
            type: .workout,
            targetCount: 1,
            currentCount: 1,
            occurrences: [occurrence(.tuesday, 18, 19)]
        ),
        Routine(
            id: "r3",
            title: "Inferior",
            type: .workout,
            targetCount: 2,
            currentCount: 0,
            occurrences: [
                occurrence(.thursday, 18, 19),
                occurrence(.saturday, 10, 11)
            ]
        )
    ]

    static let habits: [Routine] = [
        Routine(
            id: "h1",
            title: "Meditação",
            type: .habit,
            targetCount: 5,
            currentCount: 2,
            occurrences: [
                occurrence(.monday, 6, 7),
                occurrence(.tuesday, 6, 7),
                occurrence(.wednesday, 6, 7),
                occurrence(.thursday, 6, 7),
                occurrence(.friday, 6, 7)
            ]
        ),
        Routine(
            id: "h2",
            title: "Leitura",
            type: .habit,
            targetCount: 4,
            currentCount: 1,
            occurrences: [
                occurrence(.sunday, 21, 22),
                occurrence(.monday, 21, 22),
                occurrence(.wednesday, 21, 22),
                occurrence(.friday, 21, 22)
            ]
        )
    ]

    static let fixedCommitments: [FixedCommitment] = [
        FixedCommitment(
            id: "f1",
            title: "Aula de PAA",
            notes: nil,
            category: "Faculdade",
            daysOfWeek: [.monday, .thursday],
            startTime: time(9, 0),
            endTime: time(11, 0)
        ),
        FixedCommitment(
            id: "f2",
            title: "Edge Academy",
            notes: nil,
            category: "Trabalho",
            daysOfWeek: [.tuesday, .thursday],
            startTime: time(19, 0),
            endTime: time(21, 0)
        )
    ]

    /// Usado só pelo calendário de Histórico (03-calendario-historico-ui.md): inclui uma
    /// rotina de exemplo já (soft) deletada, pra exercitar o cálculo de janela
    /// createdAt/deletedAt em semanas passadas — não deve alimentar o Routine Planner.
    static var allIncludingDeleted: [Routine] {
        workouts + habits + [deletedHabitSample]
    }

    private static let deletedHabitSample: Routine = {
        let calendar = Calendar.current
        let createdAt = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        let deletedAt = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()

        return Routine(
            id: "h-deleted-1",
            title: "Yoga",
            type: .habit,
            targetCount: 3,
            currentCount: 0,
            occurrences: [
                occurrence(.tuesday, 7, 8),
                occurrence(.thursday, 7, 8),
                occurrence(.saturday, 7, 8)
            ],
            createdAt: createdAt,
            deletedAt: deletedAt
        )
    }()

    private static func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    private static func occurrence(_ weekday: Weekday, _ startHour: Int, _ endHour: Int) -> RoutineOccurrence {
        RoutineOccurrence(id: UUID().uuidString, weekday: weekday, startTime: time(startHour, 0), endTime: time(endHour, 0))
    }
}
