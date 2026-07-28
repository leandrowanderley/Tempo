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
    /// A partir de quando essa combinação dia/horário vale. Junto com `effectiveTo`,
    /// preserva o histórico ao editar (versionamento-ocorrencias-e-soft-delete-eventos.md).
    var effectiveFrom: Date = Date()
    /// `nil` = ocorrência ainda ativa. Preenchido no momento em que ela é substituída/removida.
    var effectiveTo: Date?
}

extension RoutineOccurrence {
    /// Diff entre o conjunto ativo (`effectiveTo == nil`) atual e o desejado: ocorrências
    /// iguais (mesmo dia+horário) não mexem, as que saem são fechadas (`effectiveTo = now`)
    /// em vez de descartadas, e as novas entram com `effectiveFrom = now`. Histórico já
    /// fechado em `current` é preservado intacto.
    static func diffed(current: [RoutineOccurrence], desired: [RoutineOccurrence], now: Date = Date()) -> [RoutineOccurrence] {
        func matches(_ lhs: RoutineOccurrence, _ rhs: RoutineOccurrence) -> Bool {
            lhs.weekday == rhs.weekday && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
        }

        let activeCurrent = current.filter { $0.effectiveTo == nil }
        let closedCurrent = current.filter { $0.effectiveTo != nil }

        let unchanged = activeCurrent.filter { existing in desired.contains { matches($0, existing) } }

        let newlyClosed = activeCurrent
            .filter { existing in !desired.contains { matches($0, existing) } }
            .map { occurrence -> RoutineOccurrence in
                var closed = occurrence
                closed.effectiveTo = now
                return closed
            }

        let added = desired
            .filter { candidate in !activeCurrent.contains { matches($0, candidate) } }
            .map { candidate in
                RoutineOccurrence(
                    id: UUID().uuidString,
                    weekday: candidate.weekday,
                    startTime: candidate.startTime,
                    endTime: candidate.endTime,
                    effectiveFrom: now,
                    effectiveTo: nil
                )
            }

        return closedCurrent + unchanged + newlyClosed + added
    }
}
