//
//  FixedCommitmentFormView.swift
//  Tempo
//
//  Fluxo de criação e edição de Compromissos Fixos no Routine Planner (project.md §3.4).
//  Mesmo idioma visual do EventFormView. Salva só localmente (mock) por enquanto —
//  back-end ainda não tem campo de recorrência (ver TODO.MD).
//

import SwiftUI

struct FixedCommitmentFormView: View {
    @Environment(\.dismiss) private var dismiss

    private let existingCommitment: FixedCommitment?
    private let onSave: (FixedCommitment) -> Void
    private let onDelete: (() -> Void)?

    @State private var title: String
    @State private var notes: String
    @State private var category: String
    @State private var occurrences: [RoutineOccurrence]
    @State private var isShowingAddCategory = false

    @ObservedObject private var customCategoryStore = CustomCategoryStore.shared

    private let categories = ["Faculdade", "Trabalho", "Treinos", "Habitos"]

    private var allCategoryOptions: [String] {
        categories + customCategoryStore.categories.map(\.name)
    }

    init(
        existingCommitment: FixedCommitment? = nil,
        onSave: @escaping (FixedCommitment) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingCommitment = existingCommitment
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: existingCommitment?.title ?? "")
        _notes = State(initialValue: existingCommitment?.notes ?? "")
        _category = State(initialValue: existingCommitment?.category ?? categories[0])
        _occurrences = State(initialValue: existingCommitment?.occurrences.filter { $0.effectiveTo == nil } ?? [])
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !occurrences.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                TempoTextField(title: "Título", text: $title)
                notesField
                categoryPicker
                WeekdayScheduleEditorView(occurrences: $occurrences)

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
            title: existingCommitment == nil ? "Novo Compromisso" : "Editar Compromisso",
            isConfirmEnabled: isFormValid,
            onCancel: { dismiss() },
            onConfirm: { save() }
        )
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notas")
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

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categoria")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(allCategoryOptions, id: \.self) { option in
                        categoryChip(option)
                    }

                    addCategoryChip
                }
            }
        }
        .sheet(isPresented: $isShowingAddCategory) {
            AddCategorySheetView { name, color in
                customCategoryStore.add(name: name, color: color)
                category = name
            }
        }
    }

    private var addCategoryChip: some View {
        Button {
            isShowingAddCategory = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.footnote.weight(.semibold))
                Text("Categoria")
                    .font(.footnote.weight(.medium))
            }
            .foregroundColor(.tempoPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.tempoCard)
            .overlay(
                Capsule().stroke(Color.tempoPrimary, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }

    private func categoryChip(_ option: String) -> some View {
        let isSelected = category == option
        let color = Color.forCategory(option)

        return Button {
            category = option
        } label: {
            HStack(spacing: 6) {
                CategoryDotView(category: option, size: 8)
                Text(option)
                    .font(.footnote.weight(.medium))
            }
            .foregroundColor(.tempoTextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.15) : Color.tempoCard)
            .overlay(
                Capsule().stroke(isSelected ? color : Color.tempoBorder, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }

    // TODO: Voltar a chamar APIService.deleteFixedCommitment(id:) quando o back-end estiver
    // pronto, e só remover da lista local depois da chamada ter sucesso.
    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Excluir Compromisso")
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

    // TODO: Voltar a chamar APIService.createFixedCommitment/updateFixedCommitment quando o
    // back-end estiver pronto. Por enquanto, salva só localmente (mock) e devolve pro chamador via onSave.
    private func save() {
        let versionedOccurrences = RoutineOccurrence.diffed(
            current: existingCommitment?.occurrences ?? [],
            desired: occurrences
        )

        let commitment = FixedCommitment(
            id: existingCommitment?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            category: category,
            occurrences: versionedOccurrences,
            createdAt: existingCommitment?.createdAt ?? Date()
        )

        onSave(commitment)
        dismiss()
    }
}

#Preview {
    FixedCommitmentFormView(onSave: { _ in })
}
