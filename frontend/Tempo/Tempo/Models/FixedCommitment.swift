//
//  FixedCommitment.swift
//  Tempo
//
//  Compromissos fixos recorrentes do Routine Planner (project.md §3.4).
//  Ainda não existe no back-end (Event não tem campo de recorrência — ver TODO.MD),
//  então por enquanto é uma lista somente leitura, alimentada por mock.
//

import Foundation

struct FixedCommitment: Identifiable {
    let id: String
    let title: String
    let schedule: String
    let category: String
}
