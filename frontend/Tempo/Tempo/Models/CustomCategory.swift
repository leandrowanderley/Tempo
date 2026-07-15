//
//  CustomCategory.swift
//  Tempo
//
//  Categorias criadas pelo usuário (além de Faculdade/Trabalho/Treinos/Habitos).
//  O back-end não tem uma tabela de categorias — o nome é salvo direto em Event.category,
//  então a cor da bolinha é uma preferência puramente local (Utils/CustomCategoryStore.swift).
//

import SwiftUI

struct CustomCategory: Codable, Identifiable, Equatable {
    var id: String { name }
    let name: String
    let colorHex: String

    var color: Color { Color(hex: colorHex) }
}
