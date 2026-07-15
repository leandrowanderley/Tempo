//
//  RoutinePlannerView.swift
//  Tempo
//

import SwiftUI

// TODO: Implementar steppers de metas de treino/hábitos e lista de compromissos fixos (project.md §3.4). Layout placeholder por enquanto.
struct RoutinePlannerView: View {
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(20)

            ScrollView {
                placeholder
                    .padding(.horizontal, 20)
            }
        }
        .background(Color.tempoBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Routine Planner")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            TopActionsBarView()
        }
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundColor(.tempoTextSecondary)

            Text("Routine Planner em construção")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text("Em breve: metas de treino, hábitos personalizados e compromissos fixos recorrentes.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 24)
    }
}

#Preview {
    RoutinePlannerView()
        .environmentObject(AuthViewModel())
}
