//
//  EventCardView.swift
//  Tempo
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    /// Mostra a data junto do horário — necessário na Central de Busca, que mistura
    /// ocorrências de semanas diferentes (sem isso, rotinas recorrentes viram várias
    /// linhas com o mesmo texto, parecendo duplicadas). Nas telas por dia (Home,
    /// Calendário) a data já está implícita pelo contexto, então fica desligado.
    var showsDate: Bool = false
    var onSave: (Event) -> Void = { _ in }
    var onStatusChange: (EventCompletionStatus) -> Void = { _ in }
    var onDelete: (Event) -> Void = { _ in }

    @State private var isShowingDetail = false

    private var showsCompletionToggle: Bool {
        event.isTask || event.category == "Habitos"
    }

    var body: some View {
        HStack(spacing: 12) {
            if showsCompletionToggle {
                doneToggleButton
            }

            Button {
                isShowingDetail = true
            } label: {
                HStack(spacing: 12) {
                    CategoryDotView(category: event.category)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.body)
                            .foregroundColor(event.completionStatus == .notDone ? .tempoTextPrimary : .tempoTextSecondary)
                            .strikethrough(event.completionStatus != .notDone)

                        if let notes = event.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.tempoTextSecondary)
                                .lineLimit(1)
                        }

                        statusTag
                    }

                    Spacer()

                    if !timeLabel.isEmpty {
                        Text(timeLabel)
                            .font(.subheadline)
                            .foregroundColor(.tempoTextSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    event.isLate ? Color.tempoDestructive : Color.tempoBorder,
                    lineWidth: event.isLate ? 1.5 : 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(event.completionStatus == .notDone ? 1 : 0.5)
        .sheet(isPresented: $isShowingDetail) {
            EventFormView(existingEvent: event, onSave: onSave, onDelete: onDelete)
        }
    }

    private var doneToggleButton: some View {
        Menu {
            Button("Não Feito") { onStatusChange(.notDone) }
            Button("Feito") { onStatusChange(.done) }
            Button("Cancelado", role: .destructive) { onStatusChange(.cancelled) }
        } label: {
            Image(systemName: statusIconName)
                .font(.title3)
                .foregroundColor(statusIconColor)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private var statusIconName: String {
        switch event.completionStatus {
        case .notDone: return "circle"
        case .done: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    private var statusIconColor: Color {
        switch event.completionStatus {
        case .notDone: return .tempoDisabled
        case .done: return .tempoTextPrimary
        case .cancelled: return .tempoTextSecondary
        }
    }

    private static let dateOnlyStyle = Date.FormatStyle(date: .abbreviated, time: .omitted)
        .locale(Locale(identifier: "pt_BR"))
    private static let dateTimeStyle = Date.FormatStyle(date: .abbreviated, time: .shortened)
        .locale(Locale(identifier: "pt_BR"))

    private var timeLabel: String {
        if event.isTask {
            guard let dueDate = event.endDate else { return "" }
            return "Entrega \(dueDate.formatted(date: .abbreviated, time: .shortened))"
        }
        if event.isFlexible {
            guard let end = event.endDate else { return "" }
            return "Até \(end.formatted(Self.dateOnlyStyle))"
        }
        if event.isAllDay {
            guard showsDate, let start = event.startDate else { return "Dia inteiro" }
            return start.formatted(Self.dateOnlyStyle)
        }
        guard let start = event.startDate else { return "" }
        if showsDate {
            return start.formatted(Self.dateTimeStyle)
        }
        return start.formatted(date: .omitted, time: .shortened)
    }

    @ViewBuilder
    private var statusTag: some View {
        if event.deletedAt != nil {
            tag("excluído", color: .tempoTextSecondary)
        } else if event.completionStatus == .cancelled {
            tag("Cancelado", color: .tempoTextSecondary)
        } else if event.isLate {
            tag("Atrasado", color: .tempoDestructive)
        }
    }

    private func tag(_ text: String, color: Color) -> some View {
        Text("[ \(text) ]")
            .font(.caption2.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color, lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 10) {
        EventCardView(event: Event(
            id: "1",
            title: "Aula de PAA",
            notes: nil,
            isAllDay: false,
            startDate: Date().addingTimeInterval(-7200),
            endDate: Date().addingTimeInterval(-3600),
            category: "Faculdade",
            isTask: false,
            completionStatus: .notDone
        ))
        EventCardView(event: Event(
            id: "2",
            title: "Treino de Corrida",
            notes: "5km leve",
            isAllDay: false,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date().addingTimeInterval(1800),
            category: "Treinos",
            isTask: false,
            completionStatus: .notDone
        ))
    }
    .padding()
    .background(Color.tempoBackground)
}
