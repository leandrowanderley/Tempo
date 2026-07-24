//
//  Event.swift
//  Tempo
//
//  Espelha models/event.go do back-end (BACKEND_SPECS.md §2B).
//

import Foundation

enum EventCompletionStatus: String, Codable {
    case notDone
    case done
    case cancelled
}

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var notes: String?
    var isAllDay: Bool
    var startDate: Date?
    var endDate: Date?
    var category: String
    var isTask: Bool
    var completionStatus: EventCompletionStatus = .notDone
}

extension Event {
    var isDone: Bool { completionStatus == .done }

    /// Se o horário do evento/tarefa já passou, independente de `completionStatus`.
    var hasEnded: Bool {
        if isTask {
            guard let dueDate = endDate else { return false }
            return Date() > dueDate
        }

        guard let end = endDate else { return false }
        return Date() > end
    }

    /// Atrasado: ainda não feito/cancelado e o horário já passou.
    var isLate: Bool {
        completionStatus == .notDone && hasEnded
    }
}
