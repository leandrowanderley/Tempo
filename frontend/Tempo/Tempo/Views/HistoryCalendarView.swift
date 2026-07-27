//
//  HistoryCalendarView.swift
//  Tempo
//
//  Modo "Histórico" do calendário (03-calendario-historico-ui.md): mesma estrutura de grid
//  de CalendarMonthView, mas decorada por semana (fundo laranja quando >=50% das rotinas
//  planejadas foram cumpridas) em vez de por categoria de evento.
//
//  TODO: Voltar a chamar APIService.fetchRoutineLogs(from:to:) e
//  APIService.listRoutines(includeDeleted: true) quando o back-end (docs 01/02) estiver
//  pronto. Por enquanto usa RoutineMockData/RoutineLogMockData.
//

import SwiftUI

struct HistoryCalendarView: View {
    private static let ptBRLocale = Locale(identifier: "pt_BR")

    private static var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = ptBRLocale
        return calendar
    }()

    private let calendar = HistoryCalendarView.calendar

    @State private var displayedMonth = HistoryCalendarView.calendar.startOfMonth(for: Date())
    @State private var selectedDate = HistoryCalendarView.calendar.startOfDay(for: Date())
    @State private var routines: [Routine] = []
    @State private var logs: [RoutineLog] = []

    private var isShowingCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private var logsByDay: [Date: [RoutineLog]] {
        Dictionary(grouping: logs) { calendar.startOfDay(for: $0.loggedAt) }
    }

    private var selectedDayLogs: [RoutineLog] {
        (logsByDay[calendar.startOfDay(for: selectedDate)] ?? []).sorted { $0.loggedAt < $1.loggedAt }
    }

    private var weeks: [[Date]] {
        let grid = daysInGrid
        return stride(from: 0, to: grid.count, by: 7).map { Array(grid[$0..<min($0 + 7, grid.count)]) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                monthHeader
                weekdayHeader
                monthGrid
                agendaSection
            }
            .padding(.horizontal, 20)
            .padding(.top, ScrollEdgeFadeOverlay.height)
            .padding(.bottom, Layout.tabBarClearance)
        }
        .overlay(alignment: .top) {
            ScrollEdgeFadeOverlay()
        }
        .onAppear(perform: loadData)
        .onChange(of: displayedMonth) { _, _ in loadData() }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = calendar.startOfMonth(for: Date())
                    selectedDate = calendar.startOfDay(for: Date())
                }
            } label: {
                Text(monthTitle)
                    .font(.title3.weight(.bold))
                    .foregroundColor(isShowingCurrentMonth ? .tempoPrimary : .tempoTextPrimary)
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 4) {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.tempoPrimary)
                        .frame(width: 32, height: 32)
                }

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.tempoPrimary)
                        .frame(width: 32, height: 32)
                }
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.tempoTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        VStack(spacing: 8) {
            ForEach(weeks, id: \.self) { week in
                HistoryWeekRowView(
                    days: week,
                    displayedMonth: displayedMonth,
                    selectedDate: selectedDate,
                    isHighlighted: isWeekHighlighted(week),
                    logsByDay: logsByDay,
                    calendar: calendar,
                    onSelect: selectDate
                )
            }
        }
    }

    @ViewBuilder
    private var agendaSection: some View {
        if selectedDayLogs.isEmpty {
            agendaPlaceholder
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(selectedDateTitle)
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)

                VStack(spacing: 10) {
                    ForEach(selectedDayLogs) { log in
                        RoutineLogRowView(log: log)
                    }
                }
            }
        }
    }

    private var agendaPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundColor(.tempoTextSecondary)

            Text(selectedDateTitle)
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text("Nenhuma rotina registrada nesse dia.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func selectDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = calendar.startOfDay(for: date)
            if !calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month) {
                displayedMonth = calendar.startOfMonth(for: date)
            }
        }
    }

    private func changeMonth(by offset: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = newMonth
        }
    }

    private func loadData() {
        let grid = daysInGrid
        guard let firstDay = grid.first, let lastDay = grid.last else { return }
        routines = RoutineMockData.allIncludingDeleted
        logs = RoutineLogMockData.logs(from: firstDay, to: lastDay)
    }

    /// Regra de negócio de 03-calendario-historico-ui.md: uma semana fica "em dia" quando
    /// feito/esperado >= 0.5, considerando só rotinas ativas naquela janela (createdAt/deletedAt),
    /// não a lista atual de rotinas. Semanas sem nenhuma rotina planejada ficam neutras.
    private func isWeekHighlighted(_ week: [Date]) -> Bool {
        guard let weekStart = week.first, let lastDay = week.last,
              let weekEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDay)) else { return false }
        let weekStartOfDay = calendar.startOfDay(for: weekStart)

        let activeRoutines = routines.filter { routine in
            routine.createdAt < weekEnd && (routine.deletedAt == nil || routine.deletedAt! >= weekStartOfDay)
        }
        let esperado = activeRoutines.map(\.targetCount).reduce(0, +)
        guard esperado > 0 else { return false }

        let feito = logs.filter { $0.completed && $0.loggedAt >= weekStartOfDay && $0.loggedAt < weekEnd }.count

        return Double(feito) / Double(esperado) >= 0.5
    }

    private var monthTitle: String {
        displayedMonth.formatted(Date.FormatStyle(locale: Self.ptBRLocale).month(.wide).year())
    }

    private var selectedDateTitle: String {
        selectedDate.formatted(Date.FormatStyle(locale: Self.ptBRLocale).weekday(.wide).day().month(.wide))
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }

    private var daysInGrid: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }

        let firstWeekdayOfMonth = calendar.component(.weekday, from: monthInterval.start)
        let leadingDays = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        guard let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthInterval.start) else { return [] }

        let weeksNeeded = 6
        let totalDays = weeksNeeded * 7

        return (0..<totalDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: gridStart)
        }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: self.dateComponents([.year, .month], from: date)) ?? date
    }
}

#Preview {
    HistoryCalendarView()
        .background(Color.tempoBackground)
}
