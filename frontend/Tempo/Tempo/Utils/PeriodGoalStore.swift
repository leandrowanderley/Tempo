//
//  PeriodGoalStore.swift
//  Tempo
//
//  Intenções gerais de um mês na Visão de Período (Future Log) — coisas que não são
//  nem Evento nem Tarefa ("quero socializar mais"), só um lembrete de propósito.
//  Mesmo padrão do CustomCategoryStore: singleton observável persistido em UserDefaults.
//

import Foundation
import Combine

struct PeriodGoal: Codable, Identifiable, Equatable {
    let id: String
    var title: String
    var month: Date
}

final class PeriodGoalStore: ObservableObject {
    static let shared = PeriodGoalStore()

    @Published private(set) var goals: [PeriodGoal] = []

    private let storageKey = "tempo.periodGoals"

    private init() {
        load()
    }

    func goals(for month: Date, calendar: Calendar) -> [PeriodGoal] {
        goals.filter { calendar.isDate($0.month, equalTo: month, toGranularity: .month) }
    }

    func add(title: String, month: Date) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        goals.append(PeriodGoal(id: UUID().uuidString, title: trimmed, month: month))
        save()
    }

    func rename(_ goal: PeriodGoal, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].title = trimmed
        save()
    }

    func delete(_ goal: PeriodGoal) {
        goals.removeAll { $0.id == goal.id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([PeriodGoal].self, from: data) else { return }
        goals = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
