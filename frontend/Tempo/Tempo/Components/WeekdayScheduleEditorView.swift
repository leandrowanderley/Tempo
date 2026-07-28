//
//  WeekdayScheduleEditorView.swift
//  Tempo
//
//  Picker híbrido de dias + horário, usado por FixedCommitmentFormView e RoutineFormView.
//  Modo padrão: pílulas de dia da semana + um único horário compartilhado por todos os
//  dias selecionados. Modo "horários diferentes por dia" (toggle manual): expande um card
//  de horário independente por dia selecionado, tagueado com o nome do dia.
//

import SwiftUI

struct WeekdayScheduleEditorView: View {
    @Binding var occurrences: [RoutineOccurrence]

    @State private var isPerDayMode = false
    @State private var sharedStartTime = Date()
    @State private var sharedEndTime = Date().addingTimeInterval(3600)

    private var selectedDays: Set<Weekday> {
        Set(occurrences.compactMap(\.weekday))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            weekdayPicker

            if isPerDayMode {
                perDayCards
            } else {
                sharedTimeFields
            }

            if !occurrences.isEmpty {
                toggleLink
            }
        }
        .onAppear {
            if let first = occurrences.first {
                sharedStartTime = first.startTime
                sharedEndTime = first.endTime
            }
        }
    }

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dias da Semana")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            HStack(spacing: 8) {
                ForEach(Weekday.allCases) { day in
                    weekdayChip(day)
                }
            }
        }
    }

    private func weekdayChip(_ day: Weekday) -> some View {
        let isSelected = selectedDays.contains(day)

        return Button {
            toggle(day)
        } label: {
            Text(day.shortLabel.prefix(1))
                .font(.footnote.weight(.semibold))
                .foregroundColor(isSelected ? .white : .tempoTextPrimary)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.tempoPrimary : Color.tempoCard)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isSelected ? Color.tempoPrimary : Color.tempoBorder, lineWidth: 1)
                )
        }
    }

    private func toggle(_ day: Weekday) {
        if selectedDays.contains(day) {
            occurrences.removeAll { $0.weekday == day }
        } else {
            occurrences.append(
                RoutineOccurrence(id: UUID().uuidString, weekday: day, startTime: sharedStartTime, endTime: sharedEndTime)
            )
        }
    }

    private var sharedTimeFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("Começa", selection: $sharedStartTime, displayedComponents: [.hourAndMinute])
                .foregroundColor(.tempoTextPrimary)
                .onChange(of: sharedStartTime) { applySharedTimeToAllOccurrences() }

            DatePicker("Termina", selection: $sharedEndTime, displayedComponents: [.hourAndMinute])
                .foregroundColor(.tempoTextPrimary)
                .onChange(of: sharedEndTime) { applySharedTimeToAllOccurrences() }
        }
    }

    private func applySharedTimeToAllOccurrences() {
        for index in occurrences.indices {
            occurrences[index].startTime = sharedStartTime
            occurrences[index].endTime = sharedEndTime
        }
    }

    private var perDayCards: some View {
        VStack(spacing: 10) {
            ForEach($occurrences) { $occurrence in
                perDayCard($occurrence)
            }
        }
    }

    private func perDayCard(_ occurrence: Binding<RoutineOccurrence>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let weekday = occurrence.wrappedValue.weekday {
                Text(weekday.shortLabel)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.tempoTextPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.tempoBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.tempoBorder, lineWidth: 1))
            }

            DatePicker("Início", selection: occurrence.startTime, displayedComponents: [.hourAndMinute])
                .foregroundColor(.tempoTextPrimary)

            DatePicker("Fim", selection: occurrence.endTime, displayedComponents: [.hourAndMinute])
                .foregroundColor(.tempoTextPrimary)
        }
        .padding(12)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var toggleLink: some View {
        Button {
            togglePerDayMode()
        } label: {
            Text(isPerDayMode ? "Usar o mesmo horário para todos os dias" : "Horários diferentes por dia")
                .font(.footnote.weight(.medium))
                .foregroundColor(.tempoPrimary)
        }
    }

    private func togglePerDayMode() {
        if isPerDayMode {
            if let first = occurrences.first {
                sharedStartTime = first.startTime
                sharedEndTime = first.endTime
                applySharedTimeToAllOccurrences()
            }
        }
        isPerDayMode.toggle()
    }
}

#Preview {
    WeekdayScheduleEditorView(occurrences: .constant([]))
        .padding()
        .background(Color.tempoBackground)
}
