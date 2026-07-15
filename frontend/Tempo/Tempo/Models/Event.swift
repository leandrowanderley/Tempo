//
//  Event.swift
//  Tempo
//
//  Espelha models/event.go do back-end (BACKEND_SPECS.md §2B).
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var notes: String?
    var isAllDay: Bool
    var startDate: Date?
    var endDate: Date?
    var category: String
    var isTask: Bool
    var isDone: Bool
}

extension Event {
    enum Status {
        case none
        case ongoing
        case late
    }

    var status: Status {
        guard !isDone else { return .none }

        if isTask {
            guard let dueDate = endDate else { return .none }
            return Date() > dueDate ? .late : .none
        }

        guard let start = startDate, let end = endDate else { return .none }
        let now = Date()
        if now > end { return .late }
        if now >= start && now <= end { return .ongoing }
        return .none
    }
}
