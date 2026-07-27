//
//  HistoryWeekRowView.swift
//  Tempo
//
//  Uma linha (7 dias) do grid do calendário de Histórico — fundo laranja quando a semana
//  atingiu >=50% das rotinas planejadas (03-calendario-historico-ui.md).
//

import SwiftUI

struct HistoryWeekRowView: View {
    let days: [Date]
    let displayedMonth: Date
    let selectedDate: Date
    let isHighlighted: Bool
    let logsByDay: [Date: [RoutineLog]]
    let calendar: Calendar
    let onSelect: (Date) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(days, id: \.self) { date in
                dayCell(for: date)
            }
        }
        .padding(isHighlighted ? 6 : 0)
        .background(isHighlighted ? Color.tempoStrava.opacity(0.15) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func dayCell(for date: Date) -> some View {
        let isInDisplayedMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasLogs = !(logsByDay[calendar.startOfDay(for: date)] ?? []).isEmpty

        return Button {
            onSelect(date)
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

                Circle()
                    .fill(hasLogs ? Color.tempoTextSecondary : Color.clear)
                    .frame(width: 5, height: 5)
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
}

#Preview {
    VStack(spacing: 8) {
        HistoryWeekRowView(
            days: (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) },
            displayedMonth: Date(),
            selectedDate: Date(),
            isHighlighted: true,
            logsByDay: [:],
            calendar: .current,
            onSelect: { _ in }
        )
        HistoryWeekRowView(
            days: (7..<14).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) },
            displayedMonth: Date(),
            selectedDate: Date(),
            isHighlighted: false,
            logsByDay: [:],
            calendar: .current,
            onSelect: { _ in }
        )
    }
    .padding()
    .background(Color.tempoBackground)
}
