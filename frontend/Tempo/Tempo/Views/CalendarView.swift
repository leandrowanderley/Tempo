//
//  CalendarView.swift
//  Tempo
//

import SwiftUI

struct CalendarView: View {
    private enum ViewMode {
        case week, month

        mutating func toggle() {
            self = self == .week ? .month : .week
        }

        var toggleSystemImage: String {
            switch self {
            case .week: return "rectangle.grid.1x2"
            case .month: return "rectangle.grid.3x2"
            }
        }

        var placeholderTitle: String {
            switch self {
            case .week: return "Visão Semanal"
            case .month: return "Visão Mensal"
            }
        }
    }

    @State private var viewMode: ViewMode = .week

    var body: some View {
        VStack(spacing: 0) {
            switch viewMode {
            case .week:
                placeholder
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .month:
                CalendarMonthView()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .background(Color.tempoBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewMode.toggle()
                }
            } label: {
                Image(systemName: viewMode.toggleSystemImage)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.tempoPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.tempoCard)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.tempoBorder, lineWidth: 1)
                    )
            }

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: viewMode.toggleSystemImage)
                .font(.system(size: 40))
                .foregroundColor(.tempoTextSecondary)

            Text(viewMode.placeholderTitle)
                .font(.headline)
                .foregroundColor(.tempoTextPrimary)

            Text("Estamos construindo essa tela. Volte em breve.")
                .font(.subheadline)
                .foregroundColor(.tempoTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, Layout.tabBarClearance)
    }
}

#Preview {
    CalendarView()
        .environmentObject(AuthViewModel())
}
