//
//  EventCardView.swift
//  Tempo
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    var onSave: (Event) -> Void = { _ in }

    @State private var isShowingDetail = false

    var body: some View {
        Button {
            isShowingDetail = true
        } label: {
            HStack(spacing: 12) {
                CategoryDotView(category: event.category)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.body)
                        .foregroundColor(.tempoTextPrimary)

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
            .padding()
            .background(Color.tempoCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tempoBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingDetail) {
            EventFormView(existingEvent: event, onSave: onSave)
        }
    }

    private var timeLabel: String {
        if event.isTask {
            guard let dueDate = event.endDate else { return "" }
            return "Entrega \(dueDate.formatted(date: .abbreviated, time: .shortened))"
        }
        if event.isAllDay { return "Dia inteiro" }
        guard let start = event.startDate else { return "" }
        return start.formatted(date: .omitted, time: .shortened)
    }

    @ViewBuilder
    private var statusTag: some View {
        switch event.status {
        case .late:
            tag("Atrasado", color: .tempoDestructive)
        case .ongoing:
            tag("Fazendo", color: .catWorkout)
        case .none:
            EmptyView()
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
            isDone: false
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
            isDone: false
        ))
    }
    .padding()
    .background(Color.tempoBackground)
}
