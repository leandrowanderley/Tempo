//
//  RoutinePlannerView.swift
//  Tempo
//
//  Painel de metas e regras (project.md §3.4). Dados 100% mockados por enquanto —
//  TODO: plugar em GET/POST /routines quando o back-end estiver pronto de novo.
//

import SwiftUI

struct RoutinePlannerView: View {
    @State private var workouts = RoutineMockData.workouts
    @State private var habits = RoutineMockData.habits

    @State private var isAddingWorkout = false
    @State private var isAddingHabit = false

    private let fixedCommitments = RoutineMockData.fixedCommitments

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                routineSection(
                    title: "Metas de Exercícios Físicos",
                    routines: $workouts,
                    onAdd: { isAddingWorkout = true }
                )

                routineSection(
                    title: "Hábitos Personalizados",
                    routines: $habits,
                    onAdd: { isAddingHabit = true }
                )

                fixedCommitmentsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, ScrollEdgeFadeOverlay.height)
            .padding(.bottom, Layout.tabBarClearance)
        }
        .overlay(alignment: .top) {
            ScrollEdgeFadeOverlay()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .sheet(isPresented: $isAddingWorkout) {
            AddRoutineSheetView(title: "Novo Treino") { name in
                workouts.append(Routine(id: UUID().uuidString, title: name, type: .workout, targetCount: 1, currentCount: 0))
            }
        }
        .sheet(isPresented: $isAddingHabit) {
            AddRoutineSheetView(title: "Novo Hábito") { name in
                habits.append(Routine(id: UUID().uuidString, title: name, type: .habit, targetCount: 1, currentCount: 0))
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Routine Planner")
                .font(.title2.weight(.bold))
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private func routineSection(title: String, routines: Binding<[Routine]>, onAdd: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)

                Spacer()

                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.tempoPrimary)
                }
            }

            VStack(spacing: 10) {
                ForEach(routines) { $routine in
                    RoutineGoalRowView(routine: $routine)
                }
            }
        }
    }

    private var fixedCommitmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compromissos Fixos")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            // TODO: Back-end ainda não tem campo de recorrência (ver frontend/TODO.MD) — lista só leitura por enquanto.
            VStack(spacing: 10) {
                ForEach(fixedCommitments) { commitment in
                    fixedCommitmentRow(commitment)
                }
            }
        }
    }

    private func fixedCommitmentRow(_ commitment: FixedCommitment) -> some View {
        HStack(spacing: 12) {
            CategoryDotView(category: commitment.category)

            VStack(alignment: .leading, spacing: 2) {
                Text(commitment.title)
                    .font(.body)
                    .foregroundColor(.tempoTextPrimary)

                Text(commitment.schedule)
                    .font(.caption)
                    .foregroundColor(.tempoTextSecondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RoutinePlannerView()
        .environmentObject(AuthViewModel())
}
