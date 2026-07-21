//
//  CalendarMonthView.swift
//  Tempo
//

import SwiftUI

struct CalendarMonthView: View {
    private static let ptBRLocale = Locale(identifier: "pt_BR")

    private static var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = ptBRLocale
        return calendar
    }()

    private let calendar = CalendarMonthView.calendar

    let filters: CalendarFilters

    @State private var displayedMonth = CalendarMonthView.calendar.startOfMonth(for: Date())
    @State private var selectedDate = CalendarMonthView.calendar.startOfDay(for: Date())
    @State private var allEvents: [Event] = []

    private var isShowingCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private var eventsByDay: [Date: [Event]] {
        Dictionary(grouping: allEvents.filter(filters.matches)) { event in
            calendar.startOfDay(for: event.startDate ?? Date())
        }
    }

    private var selectedDayEvents: [Event] {
        eventsByDay[calendar.startOfDay(for: selectedDate)] ?? []
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
        .onAppear(perform: loadEvents)
        .onChange(of: displayedMonth) { _, _ in loadEvents() }
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
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.tempoTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInGrid, id: \.self) { date in
                dayCell(for: date)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isInDisplayedMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let categories = topCategories(for: date)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = calendar.startOfDay(for: date)
                if !isInDisplayedMonth {
                    displayedMonth = calendar.startOfMonth(for: date)
                }
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isToday ? .bold : .regular))
                    .foregroundColor(dayTextColor(isInDisplayedMonth: isInDisplayedMonth, isToday: isToday, isSelected: isSelected))
                    .frame(width: 34, height: 34)
                    .background(isToday ? Color.tempoPrimary : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(Color.tempoPrimary, lineWidth: isSelected && !isToday ? 1 : 0)
                    )
                    .clipShape(Circle())

                HStack(spacing: 3) {
                    ForEach(categories, id: \.self) { category in
                        Circle()
                            .fill(Color.forCategory(category))
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func dayTextColor(isInDisplayedMonth: Bool, isToday: Bool, isSelected: Bool) -> Color {
        if isToday { return .white }
        if isSelected { return .tempoPrimary }
        return isInDisplayedMonth ? .tempoTextPrimary : .tempoTextSecondary.opacity(0.6)
    }

    private func topCategories(for date: Date) -> [String] {
        let events = (eventsByDay[calendar.startOfDay(for: date)] ?? [])
            .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }

        var seen: [String] = []
        for event in events where !seen.contains(event.category) {
            seen.append(event.category)
            if seen.count == 3 { break }
        }
        return seen
    }

    @ViewBuilder
    private var agendaSection: some View {
        if selectedDayEvents.isEmpty {
            agendaPlaceholder
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(selectedDateTitle)
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)

                VStack(spacing: 10) {
                    ForEach(selectedDayEvents.sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }) { event in
                        EventCardView(event: event)
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

            Text("Nenhum compromisso por aqui ainda.")
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

    private func changeMonth(by offset: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = newMonth
        }
    }

    private func loadEvents() {
        allEvents = DataMock.events(around: displayedMonth, monthsBefore: 0, monthsAfter: 0, calendar: calendar)
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
    CalendarMonthView(filters: .makeDefault())
        .background(Color.tempoBackground)
}
