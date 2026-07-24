//
//  CalendarView.swift
//  Tempo
//

import SwiftUI

struct CalendarView: View {
    private enum ViewMode {
        case month, period

        mutating func toggle() {
            self = self == .month ? .period : .month
        }

        var toggleSystemImage: String {
            switch self {
            case .month: return "rectangle.grid.3x2"
            case .period: return "rectangle.grid.1x3"
            }
        }
    }

    @State private var viewMode: ViewMode = .month
    @State private var filters = CalendarFilters.makeDefault()
    @State private var isShowingFilters = false

    var body: some View {
        VStack(spacing: 0) {
            switch viewMode {
            case .month:
                CalendarMonthView(filters: filters)
            case .period:
                CalendarPeriodView(filters: filters)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .background(Color.tempoBackground.ignoresSafeArea())
        .sheet(isPresented: $isShowingFilters) {
            CalendarFilterView(filters: $filters)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
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

                Button {
                    isShowingFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isFilterActive ? .white : .tempoPrimary)
                        .frame(width: 36, height: 36)
                        .background(isFilterActive ? Color.tempoPrimary : Color.tempoCard)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.tempoBorder, lineWidth: isFilterActive ? 0 : 1)
                        )
                }
            }

            Spacer()

            TopActionsBarView()
        }
        .padding(20)
        .background(Color.tempoBackground)
    }

    private var isFilterActive: Bool {
        filters != .makeDefault()
    }
}

#Preview {
    CalendarView()
        .environmentObject(AuthViewModel())
}
