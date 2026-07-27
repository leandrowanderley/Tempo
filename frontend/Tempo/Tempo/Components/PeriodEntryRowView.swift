//
//  PeriodEntryRowView.swift
//  Tempo
//
//  Linha "símbolo + data + título" da Visão de Período (Future Log). Dois Buttons
//  irmãos (não aninhados) porque SwiftUI não propaga toque de um Button dentro de
//  outro — o símbolo (marca/desmarca tarefa) e o texto (abre edição) precisam de
//  áreas de toque independentes.
//

import SwiftUI

struct PeriodEntryRowView: View {
    private static let ptBRLocale = Locale(identifier: "pt_BR")
    private static let calendar = Calendar.current

    let event: Event
    let font: Font
    let symbolSize: CGFloat
    var onSelect: (Event) -> Void
    var onToggleDone: (Event) -> Void

    private var isCompletedTask: Bool {
        event.isTask && event.isDone
    }

    private var symbolName: String {
        guard event.isTask else { return "square" }
        return event.isDone ? "circle.fill" : "circle"
    }

    private var textColor: Color {
        isCompletedTask ? .tempoTextSecondary : .tempoTextPrimary
    }

    private var symbolAccessibilityLabel: String {
        guard event.isTask else { return "Evento" }
        return event.isDone ? "Tarefa concluída" : "Tarefa"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Button {
                onToggleDone(event)
            } label: {
                Image(systemName: symbolName)
                    .font(.system(size: symbolSize, weight: .medium))
                    .foregroundColor(textColor)
                    .frame(width: symbolSize, height: symbolSize)
            }
            .buttonStyle(.plain)
            .disabled(!event.isTask)
            .padding(10)
            .contentShape(Rectangle())
            .padding(-10)
            .accessibilityLabel(symbolAccessibilityLabel)

            Button {
                onSelect(event)
            } label: {
                entryText
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(dateLabel): \(event.title)")
        }
    }

    private var entryText: some View {
        Text("\(dateLabel): \(event.title)")
            .font(font)
            .foregroundColor(textColor)
            .strikethrough(isCompletedTask, color: .tempoTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func isSingleDay(_ event: Event) -> Bool {
        guard let start = event.startDate, let end = event.endDate else { return true }
        return Self.calendar.isDate(start, inSameDayAs: end)
    }

    private var dateLabel: String {
        let dayMonth = Date.FormatStyle(locale: Self.ptBRLocale).day(.twoDigits).month(.twoDigits)

        if event.isTask {
            return (event.endDate ?? Date()).formatted(dayMonth)
        }

        guard let start = event.startDate, let end = event.endDate, !isSingleDay(event) else {
            return (event.startDate ?? event.endDate ?? Date()).formatted(dayMonth)
        }
        return "\(start.formatted(dayMonth)) a \(end.formatted(dayMonth))"
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        PeriodEntryRowView(
            event: Event(id: "1", title: "Aniversário da Marina", notes: nil, isAllDay: true, startDate: Date(), endDate: Date(), category: "Aniversário", isTask: false, completionStatus: .notDone),
            font: .subheadline,
            symbolSize: 14,
            onSelect: { _ in },
            onToggleDone: { _ in }
        )
        PeriodEntryRowView(
            event: Event(id: "2", title: "Entrega do TCC - versão final revisada pelo orientador", notes: nil, isAllDay: false, startDate: nil, endDate: Date(), category: "Faculdade", isTask: true, completionStatus: .notDone),
            font: .subheadline,
            symbolSize: 14,
            onSelect: { _ in },
            onToggleDone: { _ in }
        )
        PeriodEntryRowView(
            event: Event(id: "3", title: "Comprar passagem", notes: nil, isAllDay: false, startDate: nil, endDate: Date(), category: "Trabalho", isTask: true, completionStatus: .done),
            font: .subheadline,
            symbolSize: 14,
            onSelect: { _ in },
            onToggleDone: { _ in }
        )
    }
    .padding()
    .background(Color.tempoBackground)
}
