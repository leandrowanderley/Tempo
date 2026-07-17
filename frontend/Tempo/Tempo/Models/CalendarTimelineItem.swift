//
//  CalendarTimelineItem.swift
//  Tempo
//
//  Item genérico exibido na timeline semanal do Calendário (project.md §3.3).
//  Unifica Event, Routine (via RoutineOccurrence) e FixedCommitment num único formato
//  de bloco com dia+hora, já que a timeline não distingue a origem do dado — só
//  precisa saber quando ele acontece e se deve respeitar os filtros da tela.
//

import Foundation

struct CalendarTimelineItem: Identifiable, Equatable {
    let id: String
    let title: String
    let category: String
    let startDate: Date
    let endDate: Date
    let isRoutine: Bool
    let isFixedCommitment: Bool
    let isTask: Bool
}
