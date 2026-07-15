//
//  CategoryDotView.swift
//  Tempo
//

import SwiftUI

struct CategoryDotView: View {
    let category: String
    var size: CGFloat = 10

    var body: some View {
        Circle()
            .fill(Color.forCategory(category))
            .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 12) {
        CategoryDotView(category: "Faculdade")
        CategoryDotView(category: "Trabalho")
        CategoryDotView(category: "Treinos")
        CategoryDotView(category: "Habitos")
    }
    .padding()
}
