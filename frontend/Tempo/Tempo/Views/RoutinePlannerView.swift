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
    @State private var isAddingCommitment = false

    @State private var fixedCommitments = RoutineMockData.fixedCommitments

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                routineSection(
                    title: "Metas de Exercícios Físicos",
                    type: .workout,
                    routines: $workouts,
                    onAdd: { isAddingWorkout = true }
                )

                routineSection(
                    title: "Hábitos Personalizados",
                    type: .habit,
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
            RoutineFormView(type: .workout) { routine in
                workouts.append(routine)
            }
        }
        .sheet(isPresented: $isAddingHabit) {
            RoutineFormView(type: .habit) { routine in
                habits.append(routine)
            }
        }
        .sheet(isPresented: $isAddingCommitment) {
            FixedCommitmentFormView { commitment in
                fixedCommitments.append(commitment)
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

    private func routineSection(title: String, type: RoutineType, routines: Binding<[Routine]>, onAdd: @escaping () -> Void) -> some View {
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
                ForEach(routines.wrappedValue) { routine in
                    RoutineRowView(
                        routine: routine,
                        onSave: { updated in
                            if let index = routines.wrappedValue.firstIndex(where: { $0.id == updated.id }) {
                                routines.wrappedValue[index] = updated
                            }
                        },
                        onDelete: {
                            routines.wrappedValue.removeAll { $0.id == routine.id }
                        }
                    )
                }
            }
        }
    }

    private var fixedCommitmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Compromissos Fixos")
                    .font(.headline)
                    .foregroundColor(.tempoTextPrimary)

                Spacer()

                Button {
                    isAddingCommitment = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.tempoPrimary)
                }
            }

            VStack(spacing: 10) {
                ForEach(fixedCommitments) { commitment in
                    FixedCommitmentRowView(
                        commitment: commitment,
                        onSave: { updated in
                            if let index = fixedCommitments.firstIndex(where: { $0.id == updated.id }) {
                                fixedCommitments[index] = updated
                            }
                        },
                        onDelete: {
                            fixedCommitments.removeAll { $0.id == commitment.id }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    RoutinePlannerView()
        .environmentObject(AuthViewModel())
}
