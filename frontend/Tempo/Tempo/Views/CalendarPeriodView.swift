//
//  CalendarPeriodView.swift
//  Tempo
//
//  Future Log do Bullet Journal: panorama prospectivo dos próximos meses, sem
//  detalhe de agenda diária. Só entram marcos prospectivos (eventos de dia
//  inteiro/aniversários e tarefas com prazo) — ver `qualifiesForPeriodView`.
//

import SwiftUI

private enum PeriodDisplayMode: Int {
    case threeMonths = 0
    case sixMonths = 1

    var monthCount: Int { self == .threeMonths ? 3 : 6 }
    var toggleSystemImage: String { self == .threeMonths ? "rectangle.grid.1x3" : "square.grid.2x2" }
}

struct CalendarPeriodView: View {
    private static let ptBRLocale = Locale(identifier: "pt_BR")

    private static var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = ptBRLocale
        return calendar
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = ptBRLocale
        formatter.dateFormat = "MMMM"
        return formatter
    }()

    private let calendar = CalendarPeriodView.calendar

    let filters: CalendarFilters

    // Sobrevive a trocar de aba: é preferência de uso (planejamento de longo prazo),
    // não estado efêmero de navegação.
    @AppStorage("periodViewDisplayMode") private var displayModeRawValue = PeriodDisplayMode.threeMonths.rawValue
    @State private var eventsByMonth: [Date: [Event]] = [:]
    @State private var selectedEvent: Event?
    @State private var expandedMonth: Date?

    private var displayMode: PeriodDisplayMode {
        PeriodDisplayMode(rawValue: displayModeRawValue) ?? .threeMonths
    }

    // Sempre os 6 meses a partir de hoje — trocar o toggle 3↔6 só muda quantos
    // blocos são desenhados, sem precisar rebuscar nada.
    private var months: [Date] {
        let today = calendar.startOfDay(for: Date())
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return [] }
        return (0..<displayMode.monthCount).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: startOfMonth)
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    monthsContent
                }
                .padding(.horizontal, 20)
                .padding(.top, ScrollEdgeFadeOverlay.height)
                .padding(.bottom, Layout.tabBarClearance)
            }
            .overlay(alignment: .top) {
                ScrollEdgeFadeOverlay()
            }
            .onAppear(perform: loadEvents)
            .sheet(item: $selectedEvent) { event in
                EventFormView(existingEvent: event, onSave: replaceEvent)
            }

            if let month = expandedMonth {
                expandedMonthOverlay(for: month)
            }
        }
    }

    @ViewBuilder
    private func expandedMonthOverlay(for month: Date) -> some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) { expandedMonth = nil }
            }
            .transition(.opacity)

        ScrollView {
            PeriodMonthBlockView(
                monthDate: month,
                entries: sortedEntries(for: month),
                style: .wide,
                onSelect: { selectedEvent = $0 },
                onToggleDone: toggleDone
            )
        }
        .frame(maxHeight: 480)
        .contentShape(Rectangle())
        .onTapGesture {}
        .padding(.horizontal, 24)
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }

    private var header: some View {
        HStack {
            Text(periodTitle)
                .font(.title3.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            HStack(spacing: 10) {
                toggleButton(for: .threeMonths)
                toggleButton(for: .sixMonths)
            }
        }
    }

    private func toggleButton(for mode: PeriodDisplayMode) -> some View {
        let isActive = displayMode == mode

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayModeRawValue = mode.rawValue
            }
        } label: {
            Image(systemName: mode.toggleSystemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isActive ? .white : .tempoPrimary)
                .frame(width: 36, height: 36)
                .background(isActive ? Color.tempoPrimary : Color.tempoCard)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.tempoBorder, lineWidth: isActive ? 0 : 1)
                )
        }
    }

    @ViewBuilder
    private var monthsContent: some View {
        switch displayMode {
        case .threeMonths:
            VStack(alignment: .leading, spacing: 20) {
                ForEach(months, id: \.self) { month in
                    PeriodMonthBlockView(
                        monthDate: month,
                        entries: sortedEntries(for: month),
                        style: .wide,
                        onSelect: { selectedEvent = $0 },
                        onToggleDone: toggleDone
                    )
                }
            }
        case .sixMonths:
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                ForEach(months, id: \.self) { month in
                    PeriodMonthBlockView(
                        monthDate: month,
                        entries: sortedEntries(for: month),
                        style: .compact,
                        onSelect: { selectedEvent = $0 },
                        onToggleDone: toggleDone,
                        onShowMore: {
                            withAnimation(.easeInOut(duration: 0.2)) { expandedMonth = month }
                        }
                    )
                }
            }
        }
    }

    private var periodTitle: String {
        guard let firstMonth = months.first, let lastMonth = months.last else { return "" }
        let sameYear = calendar.isDate(firstMonth, equalTo: lastMonth, toGranularity: .year)

        let startLabel = sameYear ? monthName(firstMonth) : "\(monthName(firstMonth)) \(yearString(firstMonth))"
        let endLabel = "\(monthName(lastMonth)) \(yearString(lastMonth))"
        return "\(startLabel) — \(endLabel)"
    }

    private func monthName(_ date: Date) -> String {
        Self.monthFormatter.string(from: date).capitalized
    }

    private func yearString(_ date: Date) -> String {
        String(calendar.component(.year, from: date))
    }

    private func qualifiesForPeriodView(_ event: Event) -> Bool {
        if event.isTask {
            return event.endDate != nil
        }
        return event.isAllDay || event.category == "Aniversário"
    }

    private func sortedEntries(for month: Date) -> [Event] {
        (eventsByMonth[month] ?? []).sorted { lhs, rhs in
            let lhsDay = lhs.startDate ?? lhs.endDate ?? .distantFuture
            let rhsDay = rhs.startDate ?? rhs.endDate ?? .distantFuture
            if !calendar.isDate(lhsDay, inSameDayAs: rhsDay) {
                return lhsDay < rhsDay
            }
            return !lhs.isTask && rhs.isTask
        }
    }

    private func loadEvents() {
        let today = calendar.startOfDay(for: Date())
        guard let sixMonthsAhead = calendar.date(byAdding: .month, value: 6, to: today) else { return }

        let events = DataMock.periodEvents(from: today, to: sixMonthsAhead, calendar: calendar)
            .filter(qualifiesForPeriodView)
            .filter(filters.matches)

        eventsByMonth = Dictionary(grouping: events) { event in
            let reference = event.startDate ?? event.endDate ?? today
            return calendar.date(from: calendar.dateComponents([.year, .month], from: reference)) ?? today
        }
    }

    private func toggleDone(_ event: Event) {
        guard event.isTask else { return }
        updateEvent(withID: event.id) { $0.isDone.toggle() }
    }

    private func replaceEvent(_ event: Event) {
        updateEvent(withID: event.id) { $0 = event }
    }

    private func updateEvent(withID id: String, mutate: (inout Event) -> Void) {
        for (month, events) in eventsByMonth {
            guard let index = events.firstIndex(where: { $0.id == id }) else { continue }
            var updated = events
            mutate(&updated[index])
            eventsByMonth[month] = updated
            return
        }
    }
}

#Preview {
    CalendarPeriodView(filters: .makeDefault())
        .background(Color.tempoBackground)
}
