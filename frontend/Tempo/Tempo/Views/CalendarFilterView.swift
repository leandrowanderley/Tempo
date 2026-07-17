//
//  CalendarFilterView.swift
//  Tempo
//
//  Sheet de filtros da timeline do Calendário (ícone de hambúrguer no header).
//  Controla quais tipos de compromisso aparecem (rotina, compromissos fixos, tarefas)
//  e por quais categorias.
//

import SwiftUI

struct CalendarFilters: Equatable {
    var showRoutines = true
    var showFixedCommitments = true
    var showTasks = true
    var selectedCategories: Set<String>

    static func makeDefault() -> CalendarFilters {
        CalendarFilters(selectedCategories: Set(CalendarFilterView.baseCategories))
    }
}

struct CalendarFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: CalendarFilters
    @ObservedObject private var customCategoryStore = CustomCategoryStore.shared

    static let baseCategories = ["Faculdade", "Trabalho", "Treinos", "Habitos"]

    private var categories: [String] {
        Self.baseCategories + customCategoryStore.categories.map(\.name)
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
            Text("Tipos de Compromisso")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)

            toggleRow("Rotina (treinos e hábitos)", isOn: $filters.showRoutines)
            toggleRow("Compromissos Fixos", isOn: $filters.showFixedCommitments)
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
