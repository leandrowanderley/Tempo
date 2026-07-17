//
//  Weekday.swift
//  Tempo
//
//  Dia da semana usado tanto por FixedCommitment quanto pelas repetições de Routine
//  (project.md §3.4).
//

import Foundation

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .sunday: return "Dom"
        case .monday: return "Seg"
        case .tuesday: return "Ter"
        case .wednesday: return "Qua"
        case .thursday: return "Qui"
        case .friday: return "Sex"
        case .saturday: return "Sáb"
        }
    }

    static func joinedLabel(_ days: [Weekday]) -> String {
        let labels = days
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.shortLabel)

        switch labels.count {
        case 0: return ""
        case 1: return labels[0]
        default: return labels.dropLast().joined(separator: ", ") + " e " + labels[labels.count - 1]
        }
    }
}
