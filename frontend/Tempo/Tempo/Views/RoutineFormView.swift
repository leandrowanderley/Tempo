//
//  RoutineFormView.swift
//  Tempo
//
//  Fluxo de criação e edição de metas de treino/hábito no Routine Planner (project.md §3.4).
//  Mesmo idioma visual do EventFormView/FixedCommitmentFormView. Repetições (dia da
//  semana + horário) substituem o antigo stepper de meta semanal — a meta agora é
//  derivada da quantidade de repetições cadastradas. Salva só localmente (mock) por
//  enquanto — back-end ainda não tem esse formato (ver TODO.MD).
//

import SwiftUI

struct RoutineFormView: View {
    @Environment(\.dismiss) private var dismiss

    private let existingRoutine: Routine?
    private let type: RoutineType
    private let onSave: (Routine) -> Void
    private let onDelete: (() -> Void)?

    @State private var title: String
    @State private var notes: String
    @State private var occurrences: [RoutineOccurrence]

    init(
        existingRoutine: Routine? = nil,
        type: RoutineType,
        onSave: @escaping (Routine) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingRoutine = existingRoutine
        self.type = type
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: existingRoutine?.title ?? "")
        _notes = State(initialValue: existingRoutine?.notes ?? "")
        _occurrences = State(initialValue: existingRoutine?.occurrences ?? [])
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var typeLabel: String {
        type == .workout ? "Treino" : "Hábito"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                TempoTextField(title: "Título", text: $title)
                notesField
                occurrencesSection

                if let onDelete {
                    deleteButton(action: onDelete)
                }
            }
            .padding(20)
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        SheetHeaderView(
            title: existingRoutine == nil ? "Novo \(typeLabel)" : "Editar \(typeLabel)",
            isConfirmEnabled: isFormValid,
            onCancel: { dismiss() },
            onConfirm: { save() }
        )
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descrição")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            TextEditor(text: $notes)
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.tempoCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var occurrencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Repetições")
                    .font(.subheadline)
                    .foregroundColor(.tempoTextSecondary)

                Spacer()

                Button {
                    occurrences.append(
                        RoutineOccurrence(id: UUID().uuidString, weekday: nil, startTime: Date(), endTime: Date().addingTimeInterval(3600))
                    )
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.tempoPrimary)
                }
            }

            if occurrences.isEmpty {
                Text("Nenhuma repetição adicionada")
                    .font(.footnote)
                    .foregroundColor(.tempoTextSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach($occurrences) { $occurrence in
                        occurrenceRow($occurrence)
                    }
                }
            }
        }
    }

    private func occurrenceRow(_ occurrence: Binding<RoutineOccurrence>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                weekdayMenu(occurrence)

                Spacer()

                Button {
                    let id = occurrence.wrappedValue.id
                    occurrences.removeAll { $0.id == id }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.tempoDestructive)
                }
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

    private func weekdayMenu(_ occurrence: Binding<RoutineOccurrence>) -> some View {
        Menu {
            ForEach(Weekday.allCases) { day in
                Button(day.shortLabel) {
                    occurrence.wrappedValue.weekday = day
                }
            }
        } label: {
            Text(occurrence.wrappedValue.weekday?.shortLabel ?? "Dia")
                .font(.footnote.weight(.medium))
                .foregroundColor(occurrence.wrappedValue.weekday == nil ? .tempoTextSecondary : .tempoTextPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.tempoBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.tempoBorder, lineWidth: 1))
        }
    }

    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Excluir \(typeLabel)")
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundColor(.tempoDestructive)
            .padding()
            .background(Color.tempoCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Color.tempoDestructive, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func save() {
        let routine = Routine(
            id: existingRoutine?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            type: type,
            targetCount: occurrences.count,
            currentCount: existingRoutine?.currentCount ?? 0,
            occurrences: occurrences
        )

        onSave(routine)
        dismiss()
    }
}

#Preview {
    RoutineFormView(type: .workout, onSave: { _ in })
}
