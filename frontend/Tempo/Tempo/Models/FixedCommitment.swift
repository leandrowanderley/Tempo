//
//  FixedCommitment.swift
//  Tempo
//
//  Compromissos fixos recorrentes do Routine Planner (project.md §3.4).
//  Modelo espelha o formato de Event (mesmos tipos de campo — título, notas,
//  categoria, horários), mas ainda não existe no back-end (Event não tem campo de
//  recorrência — ver TODO.MD), então CRUD acontece só localmente (mock) por enquanto.
//

import Foundation

struct FixedCommitment: Codable, Identifiable {
    let id: String
    var title: String
    var notes: String?
    var category: String
    var weekdays: [Weekday]
    var startTime: Date
    var endTime: Date
}

extension FixedCommitment {
    var scheduleLabel: String {
        let daysLabel = Weekday.joinedLabel(weekdays)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeLabel = "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"

        return daysLabel.isEmpty ? timeLabel : "\(daysLabel), \(timeLabel)"
    }
}
