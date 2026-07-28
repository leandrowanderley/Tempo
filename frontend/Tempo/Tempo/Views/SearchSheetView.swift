//
//  SearchSheetView.swift
//  Tempo
//
//  Central de Busca Inteligente (project.md §3.6): pesquisa por título/notas cruzando
//  todo o histórico e futuro do usuário, dividido em "Passado" e "Presente e Futuro".
//  Por ora busca sobre DataMock — o endpoint de busca global ainda não existe no back-end
//  (API_GUIDE.md, seção "Ainda não implementado").
//

import SwiftUI

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    /// Janela deslizante em vez de carregar o histórico inteiro de uma vez: rotinas/compromissos
    /// fixos se repetem indefinidamente, então "tudo" não é um conjunto finito. Ao chegar no fim
    /// de uma seção, estende essa direção e encolhe a oposta, mantendo o total computado limitado.
    private static let windowStep = 6
    private static let minWindowMonths = 0
    private static let maxWindowMonths = 36

    @State private var monthsBefore = 6
    @State private var monthsAfter = 6

    private var allEvents: [Event] {
        DataMock.events(around: Date(), monthsBefore: monthsBefore, monthsAfter: monthsAfter)
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingResults: [Event] {
        guard !trimmedQuery.isEmpty else { return [] }

        return allEvents.filter { event in
            event.title.localizedStandardContains(trimmedQuery)
                || (event.notes?.localizedStandardContains(trimmedQuery) ?? false)
        }
    }

    private var pastResults: [Event] {
        matchingResults
            .filter { !isUpcoming($0) }
            .sorted { referenceDate($0) > referenceDate($1) }
    }

    private var upcomingResults: [Event] {
        matchingResults
            .filter { isUpcoming($0) }
            .sorted { referenceDate($0) < referenceDate($1) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchField

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if trimmedQuery.isEmpty {
                        emptyPrompt
                    } else if matchingResults.isEmpty {
                        noResults
                    } else {
                        resultsSection(title: "passado", systemImage: "arrow.down.left", events: pastResults, onReachEnd: loadMorePast)
                        resultsSection(title: "presente e futuro", systemImage: "arrow.up.right", events: upcomingResults, onReachEnd: loadMoreFuture)
                    }
                }
                .padding(20)
            }
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack {
            Text("Buscar")
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.tempoTextPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.tempoCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tempoBorder, lineWidth: 1))
            }
        }
        .padding(20)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.tempoTextSecondary)

            TextField("Evento ou tarefa...", text: $query)
                .autocorrectionDisabled()

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.tempoTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.tempoCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.tempoBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func resultsSection(
        title: String,
        systemImage: String,
        events: [Event],
        onReachEnd: @escaping () -> Void
    ) -> some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTag(title, systemImage: systemImage)

                VStack(spacing: 10) {
                    ForEach(events) { event in
                        EventCardView(event: event, showsDate: true)
                            .onAppear {
                                if event.id == events.last?.id {
                                    onReachEnd()
                                }
                            }
                    }
                }
            }
        }
    }

    /// Rolou até o fim do "passado": busca mais pra trás e libera memória encolhendo o futuro.
    private func loadMorePast() {
        guard monthsBefore < Self.maxWindowMonths else { return }
        monthsBefore = min(monthsBefore + Self.windowStep, Self.maxWindowMonths)
        monthsAfter = max(monthsAfter - Self.windowStep, Self.minWindowMonths)
    }

    /// Rolou até o fim do "presente e futuro": busca mais pra frente e encolhe o passado.
    private func loadMoreFuture() {
        guard monthsAfter < Self.maxWindowMonths else { return }
        monthsAfter = min(monthsAfter + Self.windowStep, Self.maxWindowMonths)
        monthsBefore = max(monthsBefore - Self.windowStep, Self.minWindowMonths)
    }

    private func sectionTag(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text("[ \(title) ]")
        }
        .font(.caption2.weight(.semibold))
        .foregroundColor(.tempoTextSecondary)
    }

    private var emptyPrompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundColor(.tempoTextSecondary)
            Text("Busque por eventos e tarefas do seu histórico e futuro.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var noResults: some View {
        Text("Nenhum resultado encontrado.")
            .font(.subheadline)
            .foregroundColor(.tempoTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
    }

    private func isUpcoming(_ event: Event) -> Bool {
        referenceDate(event) >= Calendar.current.startOfDay(for: Date())
    }

    private func referenceDate(_ event: Event) -> Date {
        if event.isTask {
            return event.endDate ?? .distantFuture
        }
        return event.startDate ?? event.endDate ?? .distantPast
    }
}

#Preview {
    SearchSheetView()
}
