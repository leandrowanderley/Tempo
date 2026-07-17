//
//  CalendarMockData.swift
//  Tempo
//
//  Dados estáticos pra timeline do Calendário. Sem rede — reaproveita RoutineMockData
//  (rotina + compromissos fixos) e adiciona alguns eventos avulsos, todos recorrentes
//  por dia da semana (assim como Rotina/FixedCommitment), pra popular qualquer range de
//  datas exibido na timeline.
//

import Foundation

enum CalendarMockData {
    /// Range de dias "praticamente infinito" pra timeline: N semanas antes e depois da
    /// semana atual, alinhado ao início da semana. Carregado de forma lazy pela view.
    static func dateRange(
        around referenceDate: Date = Date(),
        weeksBefore: Int = 12,
        weeksAfter: Int = 12,
        calendar: Calendar = .current
    ) -> [Date] {
        guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else { return [] }
        guard let start = calendar.date(byAdding: .day, value: -weeksBefore * 7, to: currentWeek.start) else { return [] }

        let totalDays = (weeksBefore + weeksAfter) * 7
        return (0..<totalDays).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    static func events(for dates: [Date]) -> [CalendarTimelineItem] {
        let samples: [(weekday: Weekday, hour: Int, minute: Int, durationMinutes: Int, title: String, category: String, isTask: Bool)] = [
            (.monday, 14, 0, 60, "Reunião de Projeto", "Trabalho", false),
            (.monday, 20, 30, 30, "Ligar para o dentista", "Trabalho", true),
            (.tuesday, 10, 0, 90, "Prova de Cálculo", "Faculdade", false),
            (.wednesday, 16, 0, 45, "Consulta com Orientador", "Faculdade", false),
            (.thursday, 12, 0, 60, "Corrida Livre", "Treinos", false),
            (.friday, 19, 0, 60, "Sessão de Alongamento", "Treinos", false)
        ]

        return dates.flatMap { date -> [CalendarTimelineItem] in
            samples.compactMap { sample -> CalendarTimelineItem? in
                guard Calendar.current.component(.weekday, from: date) == sample.weekday.rawValue,
                      let start = combine(date: date, hour: sample.hour, minute: sample.minute),
                      let end = Calendar.current.date(byAdding: .minute, value: sample.durationMinutes, to: start) else { return nil }

                return CalendarTimelineItem(
                    id: "event-\(sample.title)-\(Calendar.current.startOfDay(for: date).timeIntervalSince1970)",
                    title: sample.title,
                    category: sample.category,
                    startDate: start,
                    endDate: end,
                    isRoutine: false,
                    isFixedCommitment: false,
                    isTask: sample.isTask
                )
            }
        }
    }

    static func routineItems(for dates: [Date]) -> [CalendarTimelineItem] {
        let routines = RoutineMockData.workouts + RoutineMockData.habits

        return dates.flatMap { date -> [CalendarTimelineItem] in
            routines.flatMap { routine -> [CalendarTimelineItem] in
                routine.occurrences.compactMap { occurrence -> CalendarTimelineItem? in
                    guard let weekday = occurrence.weekday,
                          Calendar.current.component(.weekday, from: date) == weekday.rawValue,
                          let start = combine(date: date, time: occurrence.startTime),
                          let end = combine(date: date, time: occurrence.endTime) else { return nil }

                    return CalendarTimelineItem(
                        id: "routine-\(occurrence.id)-\(Calendar.current.startOfDay(for: date).timeIntervalSince1970)",
                        title: routine.title,
                        category: routine.type == .workout ? "Treinos" : "Habitos",
                        startDate: start,
                        endDate: end,
                        isRoutine: true,
                        isFixedCommitment: false,
                        isTask: false
                    )
                }
            }
        }
    }

    static func fixedCommitmentItems(for dates: [Date]) -> [CalendarTimelineItem] {
        dates.flatMap { date -> [CalendarTimelineItem] in
            RoutineMockData.fixedCommitments.flatMap { commitment -> [CalendarTimelineItem] in
                commitment.weekdays.compactMap { weekday -> CalendarTimelineItem? in
                    guard Calendar.current.component(.weekday, from: date) == weekday.rawValue,
                          let start = combine(date: date, time: commitment.startTime),
                          let end = combine(date: date, time: commitment.endTime) else { return nil }

                    return CalendarTimelineItem(
                        id: "fixed-\(commitment.id)-\(Calendar.current.startOfDay(for: date).timeIntervalSince1970)",
                        title: commitment.title,
                        category: commitment.category,
                        startDate: start,
                        endDate: end,
                        isRoutine: false,
                        isFixedCommitment: true,
                        isTask: false
                    )
                }
            }
        }
    }

    private static func combine(date: Date, hour: Int, minute: Int) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }

    private static func combine(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: date)
    }
}
