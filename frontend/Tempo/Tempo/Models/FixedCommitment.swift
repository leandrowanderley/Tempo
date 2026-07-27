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
    var daysOfWeek: [Weekday]
    var startTime: Date
    var endTime: Date
    var createdAt: Date = Date()
    var deletedAt: Date?
}

extension FixedCommitment {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var scheduleLabel: String {
        let daysLabel = Weekday.joinedLabel(daysOfWeek)
        let timeLabel = "\(Self.timeFormatter.string(from: startTime)) - \(Self.timeFormatter.string(from: endTime))"

        return daysLabel.isEmpty ? timeLabel : "\(daysLabel), \(timeLabel)"
    }
}
