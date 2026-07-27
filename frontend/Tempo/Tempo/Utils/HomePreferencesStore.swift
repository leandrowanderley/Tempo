//
//  HomePreferencesStore.swift
//  Tempo
//
//  Guarda quais seções da Home o usuário quer ver (ver HomeCustomizationSheetView).
//  Mesmo padrão de UserDefaults.shared do CustomCategoryStore — local, por device.
//

import Combine
import Foundation

final class HomePreferencesStore: ObservableObject {
    static let shared = HomePreferencesStore()

    @Published private(set) var enabledSections: Set<HomeSection>

    private let storageKey = "tempo.homeSections.enabled"

    private init() {
        // Sem valor salvo ainda (primeira execução) -> tudo ligado por padrão.
        enabledSections = Set(HomeSection.allCases)
        load()
    }

    func isEnabled(_ section: HomeSection) -> Bool {
        enabledSections.contains(section)
    }

    func setEnabled(_ section: HomeSection, _ value: Bool) {
        if value {
            enabledSections.insert(section)
        } else {
            enabledSections.remove(section)
        }
        save()
    }

    private func load() {
        guard let raw = UserDefaults.standard.array(forKey: storageKey) as? [String] else { return }
        enabledSections = Set(raw.compactMap(HomeSection.init(rawValue:)))
    }

    private func save() {
        UserDefaults.standard.set(enabledSections.map(\.rawValue), forKey: storageKey)
    }
}
