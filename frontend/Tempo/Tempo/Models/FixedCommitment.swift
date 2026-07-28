//
//  FixedCommitment.swift
//  Tempo
//
//  Espelha models/fixed_commitment.go do back-end (01-soft-delete-rotinas-compromissos.md §3).
//  CRUD ainda acontece só localmente (mock) — ver TODOs em FixedCommitmentFormView.swift pra
//  reconectar no APIService quando o back-end estiver pronto.
//

import Foundation

struct FixedCommitment: Codable, Identifiable {
    let id: String
    var title: String
    var notes: String?
    var category: String
    var occurrences: [RoutineOccurrence]
    var createdAt: Date = Date()
    var deletedAt: Date?
}

extension FixedCommitment {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static func timeRangeLabel(start: Date, end: Date) -> String {
        "\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
    }

    var scheduleLabel: String {
        let sortedOccurrences = occurrences.sorted { first, second -> Bool in
            let firstRank = first.weekday?.rawValue ?? 0
            let secondRank = second.weekday?.rawValue ?? 0
            return firstRank < secondRank
        }
        guard let first = sortedOccurrences.first else { return "" }

        let hasUniformTime = sortedOccurrences.allSatisfy { occurrence -> Bool in
            occurrence.startTime == first.startTime && occurrence.endTime == first.endTime
        }

        if hasUniformTime {
            let daysLabel = Weekday.joinedLabel(sortedOccurrences.compactMap(\.weekday))
            let timeLabel = Self.timeRangeLabel(start: first.startTime, end: first.endTime)
            return daysLabel.isEmpty ? timeLabel : "\(daysLabel), \(timeLabel)"
        }

        return sortedOccurrences
            .map { occurrence in
                let dayLabel = occurrence.weekday?.shortLabel ?? ""
                let timeLabel = Self.timeRangeLabel(start: occurrence.startTime, end: occurrence.endTime)
                return "\(dayLabel) \(timeLabel)"
            }
            .joined(separator: ", ")
    }
}
