//
//  EventFormView.swift
//  Tempo
//
//  Fluxo unificado de criação e edição de Evento/Tarefa (project.md §3.5).
//  Apresentado como .sheet — sobe de baixo pra cima sem cobrir a tela toda.
//

import SwiftUI

struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss

    private let existingEvent: Event?
    private let onSave: (Event) -> Void

    @State private var isTask: Bool
    @State private var title: String
    @State private var notes: String
    @State private var category: String
    @State private var isAllDay: Bool
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var isShowingAddCategory = false

    @ObservedObject private var customCategoryStore = CustomCategoryStore.shared

    private let categories = ["Faculdade", "Trabalho", "Treinos", "Habitos"]

    private var allCategoryOptions: [String] {
        categories + customCategoryStore.categories.map(\.name)
    }

    init(existingEvent: Event? = nil, onSave: @escaping (Event) -> Void = { _ in }) {
        self.existingEvent = existingEvent
        self.onSave = onSave
        _isTask = State(initialValue: existingEvent?.isTask ?? false)
        _title = State(initialValue: existingEvent?.title ?? "")
        _notes = State(initialValue: existingEvent?.notes ?? "")
        _category = State(initialValue: existingEvent?.category ?? categories[0])
        _isAllDay = State(initialValue: existingEvent?.isAllDay ?? false)
        _startDate = State(initialValue: existingEvent?.startDate ?? Date())
        _endDate = State(initialValue: existingEvent?.endDate ?? Date().addingTimeInterval(3600))
        _hasDueDate = State(initialValue: (existingEvent?.isTask ?? false) && existingEvent?.endDate != nil)
        _dueDate = State(initialValue: existingEvent?.endDate ?? Date().addingTimeInterval(3600))
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                Picker("Tipo", selection: $isTask.animation(.easeInOut)) {
                    Text("Evento").tag(false)
                    Text("Tarefa").tag(true)
                }
                .pickerStyle(.segmented)

                TempoTextField(title: "Título", text: $title)

                notesField
                categoryPicker

                if isTask {
                    taskDueDateFields
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    eventTimeFields
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(20)
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.tempoTextPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.tempoCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))
            }

            Spacer()

            Text(existingEvent == nil ? (isTask ? "Nova Tarefa" : "Novo Evento") : "Editar")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            Button {
                save()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(isFormValid ? Color.tempoPrimary : Color.tempoDisabled)
                    .clipShape(Circle())
            }
            .disabled(!isFormValid)
        }
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

    private var eventTimeFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Dia inteiro", isOn: $isAllDay.animation(.easeInOut))
                .tint(.tempoPrimary)
                .foregroundColor(.tempoTextPrimary)

            DatePicker(
                "Começa",
                selection: $startDate,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            .foregroundColor(.tempoTextPrimary)

            DatePicker(
                "Termina",
                selection: $endDate,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            .foregroundColor(.tempoTextPrimary)

            // TODO: Regras de repetição — back-end ainda não tem campo de recorrência para eventos.
        }
    }

    private var taskDueDateFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Data de entrega", isOn: $hasDueDate.animation(.easeInOut))
                .tint(.tempoPrimary)
                .foregroundColor(.tempoTextPrimary)

            if hasDueDate {
                DatePicker(
                    "Entrega",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .foregroundColor(.tempoTextPrimary)
                .transition(.opacity)
            }
        }
    }

    // TODO: Voltar a chamar APIService.createEvent/updateEvent quando o back-end estiver pronto.
    // Por enquanto, salva só localmente (mock) e devolve pro chamador via onSave.
    private func save() {
        let event = Event(
            id: existingEvent?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            isAllDay: isAllDay,
            startDate: isTask ? nil : startDate,
            endDate: isTask ? (hasDueDate ? dueDate : nil) : endDate,
            category: category,
            isTask: isTask,
            isDone: existingEvent?.isDone ?? false
        )

        onSave(event)
        dismiss()
    }
}

#Preview {
    EventFormView()
}
