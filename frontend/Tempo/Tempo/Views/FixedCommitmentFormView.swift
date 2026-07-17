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
    @State private var weekdays: Set<Weekday>
    @State private var startTime: Date
    @State private var endTime: Date
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
        _weekdays = State(initialValue: Set(existingCommitment?.weekdays ?? []))
        _startTime = State(initialValue: existingCommitment?.startTime ?? Date())
        _endTime = State(initialValue: existingCommitment?.endTime ?? Date().addingTimeInterval(3600))
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !weekdays.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                TempoTextField(title: "Título", text: $title)
                notesField
                categoryPicker
                weekdayPicker

                DatePicker("Começa", selection: $startTime, displayedComponents: [.hourAndMinute])
                    .foregroundColor(.tempoTextPrimary)

                DatePicker("Termina", selection: $endTime, displayedComponents: [.hourAndMinute])
                    .foregroundColor(.tempoTextPrimary)

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
        let isSelected = weekdays.contains(day)

        return Button {
            if isSelected {
                weekdays.remove(day)
            } else {
                weekdays.insert(day)
            }
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

    private func save() {
        let commitment = FixedCommitment(
            id: existingCommitment?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            category: category,
            weekdays: weekdays.sorted { $0.rawValue < $1.rawValue },
            startTime: startTime,
            endTime: endTime
        )

        onSave(commitment)
        dismiss()
    }
}

#Preview {
    FixedCommitmentFormView(onSave: { _ in })
}
