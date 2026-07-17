//
//  Color+Extensions.swift
//  Tempo
//

import SwiftUI

extension Color {
    static let tempoPrimary = Color(hex: "#5856D6")
    static let tempoDisabled = Color(hex: "#D1D1D6")
    static let tempoDestructive = Color(hex: "#FF3B30")

//    static let tempoBackground = Color(uiColor: .systemBackground)
    static let tempoBackground = Color(hex: "#F2F2F7")
    static let tempoCard = Color(hex: "#FFFFFF")
    static let tempoBorder = Color(hex: "#E5E5EA")
    static let tempoTextPrimary = Color(uiColor: .label)
    static let tempoTextSecondary = Color(uiColor: .secondaryLabel)

    static let catStudy = Color(hex: "#5AC8FA")
    static let catWork = Color(hex: "#FF9500")
    static let catWorkout = Color(hex: "#34C759")
    static let catHabit = Color(hex: "#AF52DE")

    static let tempoStrava = Color(hex: "#FC4C02")
    static let tempoHealth = Color(hex: "#FF2D55")

    static func forCategory(_ category: String) -> Color {
        switch category {
        case "Faculdade": return .catStudy
        case "Trabalho": return .catWork
        case "Treinos": return .catWorkout
        case "Habitos": return .catHabit
        default: return CustomCategoryStore.shared.color(for: category) ?? .tempoTextSecondary
        }
    }

    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
