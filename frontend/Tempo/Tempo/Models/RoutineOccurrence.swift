//
//  RoutineOccurrence.swift
//  Tempo
//
//  Uma repetição semanal de uma meta de treino/hábito (dia + horário), editável no
//  RoutineFormView (project.md §3.4). A meta semanal (Routine.targetCount) é derivada
//  da quantidade de repetições cadastradas.
//

import Foundation

struct RoutineOccurrence: Codable, Identifiable {
    let id: String
    var weekday: Weekday?
    var startTime: Date
    var endTime: Date
}
