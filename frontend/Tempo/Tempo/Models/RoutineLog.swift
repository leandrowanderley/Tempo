//
//  RoutineLog.swift
//  Tempo
//
//  Espelha models/routine_log.go do back-end (02-historico-rotinas-backend.md). Usado pelo
//  calendário de Histórico (03-calendario-historico-ui.md) — CRUD ainda acontece só
//  localmente (mock) — ver TODOs em HistoryCalendarView.swift pra reconectar no APIService
//  quando o back-end estiver pronto.
//

import Foundation

struct RoutineLog: Codable, Identifiable {
    let id: String
    var routineId: String?
    var name: String
    var type: RoutineType
    var loggedAt: Date
    var completed: Bool
}
