//
//  QuickStatsWidgetView.swift
//  Tempo
//
//  Barra de contadores rápidos na Home (hoje / atrasados / flexíveis / sem data).
//  Recebe as contagens já calculadas pelo HomeView pra não duplicar a lógica de
//  filtro dos eventos.
//

import SwiftUI

struct QuickStatsWidgetView: View {
    let todayCount: Int
    let overdueCount: Int
    let flexibleCount: Int
    let unscheduledCount: Int

    var body: some View {
        HStack(spacing: 0) {
            stat(systemName: "calendar", count: todayCount, label: "Hoje", color: .tempoPrimary)
            stat(systemName: "exclamationmark.triangle.fill", count: overdueCount, label: "Atrasados", color: .red)
            stat(systemName: "arrow.triangle.2.circlepath", count: flexibleCount, label: "Flexíveis", color: .orange)
            stat(systemName: "tray.fill", count: unscheduledCount, label: "Sem Data", color: .tempoTextSecondary)
        }
        .padding(.vertical, 16)
        .background(Color.tempoCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.tempoBorder, lineWidth: 1)
        )
    }

    private func stat(systemName: String, count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)

            Text("\(count)")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.tempoTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    QuickStatsWidgetView(todayCount: 4, overdueCount: 1, flexibleCount: 2, unscheduledCount: 2)
        .padding()
        .background(Color.tempoBackground)
}
