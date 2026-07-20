//
//  WeekTimelineView.swift
//  Tempo
//
//  Timeline do Calendário (project.md §3.3): colunas por dia, linhas por hora (00h-23h).
//  Colunas têm largura fixa e a lista de dias rola livremente nos dois eixos (arraste
//  lateral pra ver semanas anteriores/seguintes, dentro do range recebido em `dates`;
//  arraste vertical pra ver outras horas).
//
//  A coluna de horas é repetida a cada 7 dias (uma por semana) dentro do próprio conteúdo
//  rolável, em vez de "grudada" via rastreamento contínuo do offset de scroll — essa
//  abordagem mais simples evita recalcular o layout a cada frame de arraste (o que deixava
//  a tela travando) e ainda garante que as horas sempre apareçam a poucos dias de distância
//  de onde o usuário estiver.
//
//  Itens que se sobrepõem no mesmo dia dividem a coluna em "lanes".
//

import SwiftUI

struct WeekTimelineView: View {
    let dates: [Date]
    let items: [CalendarTimelineItem]

    private let hourHeight: CGFloat = 60
    private let hourGutterWidth: CGFloat = 40
    private let dayColumnWidth: CGFloat = 130

    @State private var itemsByDay: [Date: [CalendarTimelineItem]] = [:]

    private var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    private var todayIndex: Int {
        dates.firstIndex(where: { Calendar.current.isDateInToday($0) }) ?? 0
    }

    var body: some View {
        ScrollViewReader { horizontalProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerContent
                        .padding(.vertical, 8)

                    ScrollViewReader { verticalProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            gridContent
                                .padding(.bottom, Layout.tabBarClearance)
                        }
                        .contentMargins(.top, 0, for: .scrollContent)
                        .onAppear {
                            scrollToNow(horizontalProxy: horizontalProxy, verticalProxy: verticalProxy)
                        }
                    }
                }
            }
            .contentMargins(.top, 0, for: .scrollContent)
        }
        .task(id: items) {
            itemsByDay = Dictionary(grouping: items) { Calendar.current.startOfDay(for: $0.startDate) }
        }
    }

    private var headerContent: some View {
        LazyHStack(spacing: 0) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                if index % 7 == 0 {
                    Color.clear.frame(width: hourGutterWidth)
                }

                VStack(spacing: 4) {
                    Text(weekdayLabel(date))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.tempoTextSecondary)
                    Text(dayNumber(date))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(isToday(date) ? .tempoPrimary : .tempoTextPrimary)
                }
                .frame(width: dayColumnWidth)
            }
        }
    }

    private var gridContent: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                if index % 7 == 0 {
                    hourGutterColumn(weekIndex: index / 7)
                }

                dayColumn(date)
            }
        }
    }

    private func hourGutterColumn(weekIndex: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                Text(hourLabel(hour))
                    .font(.caption2)
                    .foregroundColor(.tempoTextSecondary)
                    .frame(width: hourGutterWidth, height: hourHeight, alignment: .top)
                    .padding(.top, 2)
                    .id(verticalScrollID(weekIndex: weekIndex, hour: hour))
            }
        }
        .id(horizontalScrollID(weekIndex: weekIndex))
    }

    private func dayColumn(_ date: Date) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(0..<24, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.tempoBorder)
                        .frame(height: 1)
                        .frame(height: hourHeight, alignment: .top)
                }
            }

            ForEach(laidOutItems(for: date)) { laidOut in
                itemCard(laidOut)
            }
        }
        .frame(width: dayColumnWidth, height: hourHeight * 24)
        .background(isToday(date) ? Color.tempoPrimary.opacity(0.05) : Color.clear)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.tempoBorder.opacity(0.6))
                .frame(width: 0.5)
        }
    }

    private struct LaidOutItem: Identifiable {
        let item: CalendarTimelineItem
        let lane: Int
        let laneCount: Int
        var id: String { item.id }
    }

    /// Alocação gulosa de "lanes": cada item entra na primeira lane já livre no horário
    /// dele; senão abre uma lane nova. Suficiente pra dividir a coluna quando dois
    /// compromissos do mesmo dia se sobrepõem (ex.: rotina + evento avulso).
    private func laidOutItems(for date: Date) -> [LaidOutItem] {
        let dayItems = (itemsByDay[Calendar.current.startOfDay(for: date)] ?? [])
            .sorted { $0.startDate < $1.startDate }
        guard !dayItems.isEmpty else { return [] }

        var laneEndTimes: [Date] = []
        var assignments: [(item: CalendarTimelineItem, lane: Int)] = []

        for item in dayItems {
            if let laneIndex = laneEndTimes.firstIndex(where: { $0 <= item.startDate }) {
                laneEndTimes[laneIndex] = item.endDate
                assignments.append((item, laneIndex))
            } else {
                laneEndTimes.append(item.endDate)
                assignments.append((item, laneEndTimes.count - 1))
            }
        }

        let laneCount = laneEndTimes.count
        return assignments.map { LaidOutItem(item: $0.item, lane: $0.lane, laneCount: laneCount) }
    }

    private func itemCard(_ laidOut: LaidOutItem) -> some View {
        let item = laidOut.item
        let startOffset = timeOffset(item.startDate)
        let duration = max(item.endDate.timeIntervalSince(item.startDate), 15 * 60)
        let height = max(CGFloat(duration / 3600) * hourHeight, 30)
        let laneWidth = dayColumnWidth / CGFloat(laidOut.laneCount)

        return HStack(alignment: .top, spacing: 4) {
            CategoryDotView(category: item.category, size: 7)
                .padding(.top, 3)
            Text(item.title)
                .font(.caption)
                .foregroundColor(.tempoTextPrimary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(width: max(laneWidth - 4, 0), height: height, alignment: .topLeading)
        .background(Color.tempoCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .position(x: CGFloat(laidOut.lane) * laneWidth + laneWidth / 2, y: startOffset + height / 2)
    }

    private func horizontalScrollID(weekIndex: Int) -> String {
        "week-\(weekIndex)"
    }

    private func verticalScrollID(weekIndex: Int, hour: Int) -> String {
        "week-\(weekIndex)-hour-\(hour)"
    }

    /// Rola até o início da semana de hoje (a coluna de horas dela fica como primeira
    /// coluna visível) e até a hora atual verticalmente. Pequeno atraso porque o scrollTo
    /// precisa que os IDs já estejam registrados no layout, o que nem sempre acontece a
    /// tempo dentro do .onAppear puro.
    private func scrollToNow(horizontalProxy: ScrollViewProxy, verticalProxy: ScrollViewProxy) {
        guard !dates.isEmpty else { return }
        let weekIndex = todayIndex / 7
        let targetHour = max(currentHour - 1, 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            horizontalProxy.scrollTo(horizontalScrollID(weekIndex: weekIndex), anchor: .leading)
            verticalProxy.scrollTo(verticalScrollID(weekIndex: weekIndex, hour: targetHour), anchor: .top)
        }
    }

    private func timeOffset(_ date: Date) -> CGFloat {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = CGFloat(components.hour ?? 0)
        let minute = CGFloat(components.minute ?? 0)
        return (hour + minute / 60) * hourHeight
    }

    private func weekdayLabel(_ date: Date) -> String {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: weekdayNumber)?.shortLabel ?? ""
    }

    private static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private func dayNumber(_ date: Date) -> String {
        Self.dayNumberFormatter.string(from: date)
    }

    private func hourLabel(_ hour: Int) -> String {
        String(format: "%02dh", hour)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

#Preview {
    let dates = CalendarMockData.dateRange()

    return WeekTimelineView(
        dates: dates,
        items: CalendarMockData.events(for: dates)
            + CalendarMockData.routineItems(for: dates)
            + CalendarMockData.fixedCommitmentItems(for: dates)
    )
    .background(Color.tempoBackground)
}
