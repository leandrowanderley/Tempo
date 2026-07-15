//
//  APIConfig.swift
//  Tempo
//

import Foundation

enum APIConfig {
    // TODO: Trocar para a URL de produção quando o back-end Go for publicado.
    static let baseURL = URL(string: "http://localhost:8080/api/v1")!
}
