//
//  CalendarFilterView.swift
//  Tempo
//
//  Sheet de filtros do Calendário (botão de filtro no header). Controla quais tipos
//  de compromisso aparecem (Eventos, Tarefas) e por quais categorias.
//

import SwiftUI

struct CalendarFilters: Equatable {
    var showEvents = true
    var showTasks = true
    var selectedCategories: Set<String>

    static let baseCategories = ["Faculdade", "Trabalho", "Treinos", "Habitos"]

    static func makeDefault() -> CalendarFilters {
        CalendarFilters(selectedCategories: Set(baseCategories))
    }

    func matches(_ event: Event) -> Bool {
        guard selectedCategories.contains(event.category) else { return false }
        return event.isTask ? showTasks : showEvents
    }
}

struct CalendarFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: CalendarFilters
    @ObservedObject private var customCategoryStore = CustomCategoryStore.shared

    private var categories: [String] {
        CalendarFilters.baseCategories + customCategoryStore.categories.map(\.name)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                typeFiltersSection
                categoryFiltersSection
            }
            .padding(20)
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        SheetHeaderView(
            title: "Filtros",
            onCancel: { dismiss() },
            onConfirm: { dismiss() }
        )
    }

    private var typeFiltersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tipo")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            toggleRow("Eventos", isOn: $filters.showEvents)
            toggleRow("Tarefas", isOn: $filters.showTasks)
        }
    }

    private var categoryFiltersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categorias")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            VStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryRow(category)
                }
            }
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.body)
                .foregroundColor(.tempoTextPrimary)
        }
        .tint(.tempoPrimary)
        .padding(12)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func categoryRow(_ category: String) -> some View {
        let isSelected = filters.selectedCategories.contains(category)

        return Button {
            if isSelected {
                filters.selectedCategories.remove(category)
            } else {
                filters.selectedCategories.insert(category)
            }
        } label: {
            HStack {
                CategoryDotView(category: category)
                Text(category)
                    .foregroundColor(.tempoTextPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .tempoPrimary : .tempoTextSecondary)
            }
            .padding(12)
            .background(Color.tempoCard)
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(Color.tempoBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CalendarFilterView(filters: .constant(.makeDefault()))
}
