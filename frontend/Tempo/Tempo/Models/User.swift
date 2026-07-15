//
//  User.swift
//  Tempo
//
//  Espelha models/user.go do back-end.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let birthDate: String?
    let stravaConnected: Bool
    let appleConnected: Bool
}
