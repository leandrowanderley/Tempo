//
//  RoutineLogMockData.swift
//  Tempo
//
//  Dados estáticos pro calendário de Histórico (03-calendario-historico-ui.md). Sem rede —
//  gera um RoutineLog por (rotina, dia planejado) dentro do intervalo pedido, reaproveitando
//  as repetições já cadastradas em RoutineMockData. O status `completed` é determinístico
//  (mesma semana sempre dá o mesmo resultado) só pra dar variedade visual entre semanas
//  "em dia" e semanas abaixo de 50% — não é uma simulação estatística de verdade.
//

import Foundation

enum RoutineLogMockData {
    private static let calendar = Calendar.current

    static func logs(from startDate: Date, to endDate: Date) -> [RoutineLog] {
        let dates = dateRange(from: startDate, to: endDate)
        let routines = RoutineMockData.allIncludingDeleted

        return dates.flatMap { date -> [RoutineLog] in
            routines.compactMap { routine -> RoutineLog? in
                guard isRoutineActive(routine, on: date),
                      let occurrence = routine.occurrences.first(where: { $0.weekday?.rawValue == calendar.component(.weekday, from: date) })
                else { return nil }

                return RoutineLog(
                    id: "log-\(routine.id)-\(Int(calendar.startOfDay(for: date).timeIntervalSince1970))",
                    routineId: routine.id,
                    name: routine.title,
                    type: routine.type,
                    loggedAt: combine(date: date, time: occurrence.startTime) ?? date,
                    completed: isCompleted(routine: routine, date: date)
                )
            }
        }
    }

    private static func isRoutineActive(_ routine: Routine, on date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        if day < calendar.startOfDay(for: routine.createdAt) { return false }
        if let deletedAt = routine.deletedAt, day > calendar.startOfDay(for: deletedAt) { return false }
        return true
    }

    private static func isCompleted(routine: Routine, date: Date) -> Bool {
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let seed = weekOfYear + stableSeed(routine.id)
        return seed % 10 < 7
    }

    private static func stableSeed(_ string: String) -> Int {
        string.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }

    private static func dateRange(from startDate: Date, to endDate: Date) -> [Date] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [] }

        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }

    private static func combine(date: Date, time: Date) -> Date? {
        let components = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: date)
    }
}
