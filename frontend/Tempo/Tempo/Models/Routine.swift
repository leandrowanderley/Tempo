//
//  Routine.swift
//  Tempo
//
//  Espelha models/routine.go do back-end (BACKEND_SPECS.md §2C).
//

import Foundation

enum RoutineType: String, Codable {
    case workout
    case habit
}

struct Routine: Codable, Identifiable {
    let id: String
    var title: String
    var type: RoutineType
    var targetCount: Int
    var currentCount: Int
}

extension Routine {
    var progress: Double {
        guard targetCount > 0 else { return 0 }
        return min(Double(currentCount) / Double(targetCount), 1)
    }
}
