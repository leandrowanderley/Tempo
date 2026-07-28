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
        WeekdayScheduleEditorView(occurrences: $occurrences)
    }

    // TODO: Voltar a chamar APIService.deleteRoutine(id:) quando o back-end estiver pronto, e
    // só remover da lista local depois da chamada ter sucesso.
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

    // TODO: Voltar a chamar APIService.createRoutine/updateRoutine quando o back-end estiver
    // pronto (endpoints ainda não existem — só DeleteRoutine foi adicionado em
    // 01-soft-delete-rotinas-compromissos.md). Por enquanto, salva só localmente (mock).
    private func save() {
        let routine = Routine(
            id: existingRoutine?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            type: type,
            targetCount: occurrences.count,
            currentCount: existingRoutine?.currentCount ?? 0,
            occurrences: occurrences,
            createdAt: existingRoutine?.createdAt ?? Date()
        )

        onSave(routine)
        dismiss()
    }
}

#Preview {
    RoutineFormView(type: .workout, onSave: { _ in })
}
