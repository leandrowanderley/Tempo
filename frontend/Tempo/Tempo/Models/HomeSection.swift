//
//  HomeSection.swift
//  Tempo
//
//  Seções que compõem a Home. Usado pela tela de personalização (SF Symbols +
//  toggle) e pelo HomeView pra decidir o que renderizar — ver HomePreferencesStore.
//

import Foundation

enum HomeSection: String, Codable, CaseIterable, Identifiable {
    case dailyQuote
    case weeklyProgress
    case quickStats
    case today
    case overdue
    case flexible
    case unscheduled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dailyQuote: return "Frase do Dia"
        case .weeklyProgress: return "Progresso Semanal"
        case .quickStats: return "Resumo Rápido"
        case .today: return "O Que Temos Hoje"
        case .overdue: return "Atrasados"
        case .flexible: return "Eventos Flexíveis"
        case .unscheduled: return "Sem Data"
        }
    }

    var sfSymbol: String {
        switch self {
        case .dailyQuote: return "quote.bubble.fill"
        case .weeklyProgress: return "balloon.fill"
        case .quickStats: return "chart.bar.doc.horizontal"
        case .today: return "calendar"
        case .overdue: return "exclamationmark.triangle.fill"
        case .flexible: return "arrow.triangle.2.circlepath"
        case .unscheduled: return "tray.fill"
        }
    }

    /// Ordem fixa de exibição na Home — o toggle só liga/desliga, não reordena.
    static let defaultOrder: [HomeSection] = [
        .dailyQuote, .weeklyProgress, .quickStats, .today, .overdue, .flexible, .unscheduled
    ]
}
