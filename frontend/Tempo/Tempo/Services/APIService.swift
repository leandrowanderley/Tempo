//
//  APIService.swift
//  Tempo
//
//  Camada de rede para a API Go. Todo request autenticado exige o access
//  token do Supabase Auth (RequireAuth do back-end valida via JWKS).
//

import Auth
import Foundation
import Supabase

enum APIError: Error {
    case notAuthenticated
    case requestFailed(statusCode: Int)
}

enum APIService {
    private static func makeRequest(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        guard let accessToken = SupabaseService.client.auth.currentSession?.accessToken else {
            throw APIError.notAuthenticated
        }

        var url = APIConfig.baseURL.appendingPathComponent(path)
        if let queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            url = components?.url ?? url
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }

    private static func send<T: Decodable>(_ request: URLRequest, expecting statusCode: Int) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == statusCode else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.requestFailed(statusCode: code)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    private static func sendNoContent(_ request: URLRequest, expecting statusCode: Int) async throws {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == statusCode else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.requestFailed(statusCode: code)
        }
    }

    static func fetchProfile() async throws -> User {
        let request = try makeRequest(path: "profile")
        return try await send(request, expecting: 200)
    }

    static func createEvent(_ event: Event) async throws -> Event {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let request = try makeRequest(path: "events", method: "POST", body: try encoder.encode(event))
        return try await send(request, expecting: 201)
    }

    static func updateEvent(id: String, _ event: Event) async throws -> Event {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let request = try makeRequest(path: "events/\(id)", method: "PUT", body: try encoder.encode(event))
        return try await send(request, expecting: 200)
    }

    // Soft delete: linha continua no banco com deletedAt preenchido (ver
    // 01-soft-delete-rotinas-compromissos.md), mas some das listagens.
    static func deleteRoutine(id: String) async throws {
        let request = try makeRequest(path: "routines/\(id)", method: "DELETE")
        try await sendNoContent(request, expecting: 204)
    }

    // `includeDeleted` é o complemento ao doc 01/02 pedido em 03-calendario-historico-ui.md:
    // o calendário de Histórico precisa enxergar rotinas já (soft) deletadas pra calcular
    // corretamente a janela createdAt/deletedAt de semanas passadas.
    static func listRoutines(includeDeleted: Bool = false) async throws -> [Routine] {
        let queryItems = includeDeleted ? [URLQueryItem(name: "includeDeleted", value: "true")] : nil
        let request = try makeRequest(path: "routines", queryItems: queryItems)
        return try await send(request, expecting: 200)
    }

    static func listFixedCommitments() async throws -> [FixedCommitment] {
        let request = try makeRequest(path: "fixed-commitments")
        return try await send(request, expecting: 200)
    }

    static func createFixedCommitment(_ commitment: FixedCommitment) async throws -> FixedCommitment {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let request = try makeRequest(path: "fixed-commitments", method: "POST", body: try encoder.encode(commitment))
        return try await send(request, expecting: 201)
    }

    static func updateFixedCommitment(id: String, _ commitment: FixedCommitment) async throws -> FixedCommitment {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let request = try makeRequest(path: "fixed-commitments/\(id)", method: "PUT", body: try encoder.encode(commitment))
        return try await send(request, expecting: 200)
    }

    // Soft delete, mesmo padrão de deleteRoutine.
    static func deleteFixedCommitment(id: String) async throws {
        let request = try makeRequest(path: "fixed-commitments/\(id)", method: "DELETE")
        try await sendNoContent(request, expecting: 204)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    // Ver 02-historico-rotinas-backend.md — usado pelo calendário de Histórico (doc 03).
    static func fetchRoutineLogs(from: Date, to: Date) async throws -> [RoutineLog] {
        let queryItems = [
            URLQueryItem(name: "from", value: dayFormatter.string(from: from)),
            URLQueryItem(name: "to", value: dayFormatter.string(from: to))
        ]
        let request = try makeRequest(path: "routine-logs", queryItems: queryItems)
        return try await send(request, expecting: 200)
    }

    // Find-or-create diário: mesmo dia registrado de novo atualiza a linha em vez de duplicar.
    static func logRoutine(id: String, date: Date, completed: Bool) async throws -> RoutineLog {
        struct RoutineLogRequest: Encodable {
            let date: String
            let completed: Bool
        }

        let body = RoutineLogRequest(date: dayFormatter.string(from: date), completed: completed)
        let request = try makeRequest(path: "routines/\(id)/logs", method: "POST", body: try JSONEncoder().encode(body))
        return try await send(request, expecting: 200)
    }
}
