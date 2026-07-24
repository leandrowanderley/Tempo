//
//  PeriodMonthBlockView.swift
//  Tempo
//
//  Card de um mês na Visão de Período (Future Log). Burro de propósito quanto a
//  eventos/tarefas: só recebe `entries` já filtradas/ordenadas e desenha — quem
//  decide range, meses e modo (3/6) é a CalendarPeriodView. As intenções gerais do
//  mês (nem Evento nem Tarefa, ex. "quero socializar mais") são a exceção: o bloco
//  lê/escreve direto no PeriodGoalStore, mesmo padrão que EventFormView usa com o
//  CustomCategoryStore.
//

import SwiftUI

enum PeriodBlockStyle {
    case wide     // modo 3 meses
    case compact  // modo 6 meses
}

struct PeriodMonthBlockView: View {
    private static let ptBRLocale = Locale(identifier: "pt_BR")
    private static let calendar = Calendar.current

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = ptBRLocale
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let compactCardHeight: CGFloat = 210
    // compactCardHeight menos padding vertical do card e a altura do título+divisor.
    private static let compactItemsHeight: CGFloat = 150

    let monthDate: Date
    let entries: [Event]
    let style: PeriodBlockStyle
    var onSelect: (Event) -> Void
    var onToggleDone: (Event) -> Void
    var onShowMore: () -> Void = {}

    @ObservedObject private var goalStore = PeriodGoalStore.shared
    @State private var selectedGoal: PeriodGoal?
    @State private var isRenamingGoal = false
    @State private var renameText = ""
    @State private var isAddingGoal = false
    @State private var newGoalText = ""

    private var isCurrentMonth: Bool {
        Self.calendar.isDate(monthDate, equalTo: Date(), toGranularity: .month)
    }

    private var monthTitle: String {
        Self.monthFormatter.string(from: monthDate).capitalized
    }

    private var monthGoals: [PeriodGoal] {
        goalStore.goals(for: monthDate, calendar: Self.calendar)
    }

    private var cardPadding: CGFloat { style == .wide ? 16 : 10 }
    private var titleFont: Font { style == .wide ? .title3.weight(.bold) : .subheadline.weight(.bold) }
    private var entryFont: Font { style == .wide ? .subheadline : .caption }
    private var symbolSize: CGFloat { style == .wide ? 14 : 11 }
    private var entrySpacing: CGFloat { style == .wide ? 8 : 5 }
    private var dividerSpacing: CGFloat { style == .wide ? 12 : 8 }


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(monthTitle)
                    .font(titleFont)
                    .foregroundColor(isCurrentMonth ? .tempoPrimary : .tempoTextPrimary)

                Spacer(minLength: 4)

                addGoalButton
            }

            Divider()
                .background(Color.tempoBorder)
                .padding(.vertical, dividerSpacing)

            content
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: style == .compact ? Self.compactCardHeight : nil, alignment: .top)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .confirmationDialog(
            "O que fazer com essa nota?",
            isPresented: Binding(
                get: { selectedGoal != nil },
                set: { isPresented in if !isPresented { selectedGoal = nil } }
            ),
            titleVisibility: .visible,
            presenting: selectedGoal
        ) { goal in
            Button("Renomear") {
                renameText = goal.title
                isRenamingGoal = true
            }
            Button("Excluir", role: .destructive) {
                goalStore.delete(goal)
            }
            Button("Cancelar", role: .cancel) {}
        }
        .alert("Renomear nota", isPresented: $isRenamingGoal) {
            TextField("Nome", text: $renameText)
            Button("Salvar") {
                if let goal = selectedGoal { goalStore.rename(goal, to: renameText) }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .alert("Nova nota", isPresented: $isAddingGoal) {
            TextField("Ex.: quero socializar mais", text: $newGoalText)
            Button("Adicionar") {
                goalStore.add(title: newGoalText, month: monthDate)
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: entrySpacing) {
            if entries.isEmpty && monthGoals.isEmpty {
                Text("Nada planejado ainda")
                    .font(entryFont)
                    .foregroundColor(.tempoTextSecondary)
            } else if style == .compact {
                // Altura fixa (não GeometryReader — isso causava um loop de layout e a
                // tela inteira ficava "fantasma"/piscando). A lista ocupa esse espaço
                // e é cortada; o botão fica fixo no rodapé, sobreposto, com um fundo
                // que vai de transparente a branco sólido, escondendo por completo
                // (não só sobrepondo) o que passar por baixo dele.
                ZStack(alignment: .bottom) {
                    itemsList
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [Color.tempoCard.opacity(0), Color.tempoCard],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)

                        HStack {
                            Button(action: onShowMore) {
                                Text("Ver mês completo")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.tempoPrimary)
                            }
                            .buttonStyle(.plain)

                            Spacer(minLength: 0)
                        }
                        .padding(.top, 2)
                        .background(Color.tempoCard)
                    }
                }
                .frame(height: Self.compactItemsHeight, alignment: .top)
                .clipped()
            } else {
                itemsList
            }
        }
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: entrySpacing) {
            ForEach(entries) { event in
                PeriodEntryRowView(
                    event: event,
                    font: entryFont,
                    symbolSize: symbolSize,
                    onSelect: onSelect,
                    onToggleDone: onToggleDone
                )
            }

            ForEach(monthGoals) { goal in
                PeriodGoalRowView(
                    goal: goal,
                    font: entryFont,
                    symbolSize: symbolSize,
                    onTap: { selectedGoal = $0 }
                )
            }
        }
    }

    private var addGoalButton: some View {
        Button {
            newGoalText = ""
            isAddingGoal = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: style == .wide ? 15 : 12, weight: .semibold))
                .foregroundColor(.tempoPrimary)
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            PeriodMonthBlockView(
                monthDate: Date(),
                entries: [
                    Event(id: "1", title: "Aniversário da Marina", notes: nil, isAllDay: true, startDate: Date(), endDate: Date(), category: "Aniversário", isTask: false, isDone: false),
                    Event(id: "2", title: "Entrega do TCC", notes: nil, isAllDay: false, startDate: nil, endDate: Date(), category: "Faculdade", isTask: true, isDone: false)
                ],
                style: .wide,
                onSelect: { _ in },
                onToggleDone: { _ in }
            )
            PeriodMonthBlockView(monthDate: Date(), entries: [], style: .wide, onSelect: { _ in }, onToggleDone: { _ in })
        }
        .padding()
    }
    .background(Color.tempoBackground)
}
