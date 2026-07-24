//
//  CustomCategoryStore.swift
//  Tempo
//

import Combine
import SwiftUI

final class CustomCategoryStore: ObservableObject {
    static let shared = CustomCategoryStore()

    @Published private(set) var categories: [CustomCategory] = []

    private let storageKey = "tempo.customCategories"

    private init() {
        load()
    }

    func add(name: String, color: Color) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              !categories.contains(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }

        categories.append(CustomCategory(name: trimmed, colorHex: color.toHex()))
        save()
    }

    func color(for name: String) -> Color? {
        categories.first(where: { $0.name == name })?.color
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CustomCategory].self, from: data) else { return }
        categories = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
