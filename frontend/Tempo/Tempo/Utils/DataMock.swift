//
//  DataMock.swift
//  Tempo
//
//  Dados estáticos pro Calendário. Sem rede — reaproveita RoutineMockData (rotinas e
//  compromissos fixos) e adiciona alguns eventos avulsos, todos recorrentes por dia da
//  semana, pra popular qualquer range de meses exibido na visão mensal/semanal.
//

import Foundation

enum DataMock {
    /// Busca eventos exatamente no intervalo `[startDate, endDate]` (ambos inclusivos, por dia).
    /// É a função a ser usada por qualquer view (mensal, semanal, etc.) — pede só os dias que
    /// de fato serão exibidos, no mesmo formato de range que a API real vai receber
    /// (equivalente a um futuro `GET /api/v1/events?from=&to=`).
    static func events(
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> [Event] {
        let dates = dateRange(from: startDate, to: endDate, calendar: calendar)

        return oneOffEvents(for: dates, calendar: calendar)
            + routineEvents(for: dates, calendar: calendar)
            + fixedCommitmentEvents(for: dates, calendar: calendar)
            + fixedDateEvents(for: dates, calendar: calendar)
    }

    /// Fonte dedicada da Visão de Período (Future Log do Bullet Journal): só os marcos de
    /// data fixa (aniversários, viagens, entregas importantes) — nunca a agenda recorrente
    /// semanal (compromissos/tarefas do dia a dia), que faria a página perder a simplicidade
    /// que é o ponto central do método.
    static func periodEvents(
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> [Event] {
        fixedDateEvents(for: dateRange(from: startDate, to: endDate, calendar: calendar), calendar: calendar)
    }

    /// Conveniência sobre `events(from:to:)` para quando o chamador pensa em "meses ao redor
    /// de uma data" em vez de um range explícito de dias.
    static func events(
        around referenceDate: Date = Date(),
        monthsBefore: Int = 2,
        monthsAfter: Int = 2,
        calendar: Calendar = .current
    ) -> [Event] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: referenceDate),
              let start = calendar.date(byAdding: .month, value: -monthsBefore, to: monthInterval.start),
              let endExclusive = calendar.date(byAdding: .month, value: monthsAfter + 1, to: monthInterval.start),
              let end = calendar.date(byAdding: .day, value: -1, to: endExclusive) else { return [] }

        return events(from: start, to: end, calendar: calendar)
    }

    private static func dateRange(from startDate: Date, to endDate: Date, calendar: Calendar) -> [Date] {
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

    private static func oneOffEvents(for dates: [Date], calendar: Calendar) -> [Event] {
        let samples: [(weekday: Weekday, hour: Int, minute: Int, durationMinutes: Int, title: String, notes: String?, category: String, isTask: Bool)] = [
            (.monday, 14, 0, 60, "Reunião de Projeto", nil, "Trabalho", false),
            (.monday, 20, 30, 30, "Ligar para o dentista", nil, "Trabalho", true),
            (.tuesday, 10, 0, 90, "Prova de Cálculo", "Sala 204", "Faculdade", false),
            (.wednesday, 16, 0, 45, "Consulta com Orientador", nil, "Faculdade", false),
            (.thursday, 12, 0, 60, "Corrida Livre", "5km leve", "Treinos", false),
            (.friday, 19, 0, 60, "Sessão de Alongamento", nil, "Treinos", false),
            (.saturday, 9, 0, 60, "Compras da Semana", nil, "Trabalho", true),
            (.sunday, 11, 0, 90, "Almoço em Família", nil, "Habitos", false)
        ]

        return dates.flatMap { date -> [Event] in
            samples.compactMap { sample -> Event? in
                guard calendar.component(.weekday, from: date) == sample.weekday.rawValue,
                      let start = calendar.date(bySettingHour: sample.hour, minute: sample.minute, second: 0, of: date),
                      let end = calendar.date(byAdding: .minute, value: sample.durationMinutes, to: start) else { return nil }

                return Event(
                    id: "mock-\(sample.title)-\(Int(calendar.startOfDay(for: date).timeIntervalSince1970))",
                    title: sample.title,
                    notes: sample.notes,
                    isAllDay: false,
                    startDate: start,
                    endDate: end,
                    category: sample.category,
                    isTask: sample.isTask,
                    completionStatus: .notDone
                )
            }
        }
    }

    private static func routineEvents(for dates: [Date], calendar: Calendar) -> [Event] {
        let routines = RoutineMockData.workouts + RoutineMockData.habits

        return dates.flatMap { date -> [Event] in
            routines.flatMap { routine -> [Event] in
                routine.occurrences.compactMap { occurrence -> Event? in
                    guard let weekday = occurrence.weekday,
                          calendar.component(.weekday, from: date) == weekday.rawValue,
                          let start = combine(date: date, time: occurrence.startTime, calendar: calendar),
                          let end = combine(date: date, time: occurrence.endTime, calendar: calendar) else { return nil }

                    return Event(
                        id: "routine-\(occurrence.id)-\(Int(calendar.startOfDay(for: date).timeIntervalSince1970))",
                        title: routine.title,
                        notes: nil,
                        isAllDay: false,
                        startDate: start,
                        endDate: end,
                        category: routine.type == .workout ? "Treinos" : "Habitos",
                        isTask: false,
                        completionStatus: .notDone
                    )
                }
            }
        }
    }

    private static func fixedCommitmentEvents(for dates: [Date], calendar: Calendar) -> [Event] {
        dates.flatMap { date -> [Event] in
            RoutineMockData.fixedCommitments.flatMap { commitment -> [Event] in
                commitment.weekdays.compactMap { weekday -> Event? in
                    guard calendar.component(.weekday, from: date) == weekday.rawValue,
                          let start = combine(date: date, time: commitment.startTime, calendar: calendar),
                          let end = combine(date: date, time: commitment.endTime, calendar: calendar) else { return nil }

                    return Event(
                        id: "fixed-\(commitment.id)-\(Int(calendar.startOfDay(for: date).timeIntervalSince1970))",
                        title: commitment.title,
                        notes: commitment.notes,
                        isAllDay: false,
                        startDate: start,
                        endDate: end,
                        category: commitment.category,
                        isTask: false,
                        completionStatus: .notDone
                    )
                }
            }
        }
    }

    private struct FixedSample {
        let month: Int
        let day: Int
        let durationDays: Int
        let title: String
        let category: String
        let isTask: Bool
    }

    /// Marcos de data fixa (mês+dia), não recorrentes por dia da semana — poucos, e só os
    /// realmente importantes: aniversários, uma viagem, entregas com prazo certo. É de propósito
    /// uma lista curta (§7 do spec: "poucos itens é o objetivo, não uma limitação").
    private static let fixedSamples: [FixedSample] = [
        FixedSample(month: 7, day: 30, durationDays: 1, title: "Aniversário da Marina", category: "Aniversário", isTask: false),
        FixedSample(month: 8, day: 20, durationDays: 5, title: "Viagem a SP", category: "Trabalho", isTask: false),
        FixedSample(month: 8, day: 28, durationDays: 1, title: "Entrega do TCC", category: "Faculdade", isTask: true),
        FixedSample(month: 9, day: 12, durationDays: 1, title: "Aniversário do Pedro", category: "Aniversário", isTask: false),
        FixedSample(month: 10, day: 6, durationDays: 1, title: "Prova Final de Cálculo", category: "Faculdade", isTask: true),
        FixedSample(month: 11, day: 3, durationDays: 1, title: "Formatura", category: "Faculdade", isTask: false),
        FixedSample(month: 12, day: 24, durationDays: 2, title: "Ceia de Natal em Família", category: "Habitos", isTask: false)
    ]

    private static func fixedDateEvents(for dates: [Date], calendar: Calendar) -> [Event] {
        dates.compactMap { date -> Event? in
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            guard let year = components.year, let month = components.month, let day = components.day,
                  let sample = fixedSamples.first(where: { $0.month == month && $0.day == day }),
                  let start = calendar.date(from: DateComponents(year: year, month: sample.month, day: sample.day)),
                  let end = calendar.date(byAdding: .day, value: sample.durationDays - 1, to: start) else { return nil }

            return Event(
                id: "fixed-date-\(sample.title)-\(year)",
                title: sample.title,
                notes: nil,
                isAllDay: !sample.isTask,
                startDate: sample.isTask ? nil : start,
                endDate: end,
                category: sample.category,
                isTask: sample.isTask,
                completionStatus: .notDone
            )
        }
    }

    private static func combine(date: Date, time: Date, calendar: Calendar) -> Date? {
        let components = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: date)
    }
}
