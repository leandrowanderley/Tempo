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
    private static func makeRequest(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let accessToken = SupabaseService.client.auth.currentSession?.accessToken else {
            throw APIError.notAuthenticated
        }

        var request = URLRequest(url: APIConfig.baseURL.appendingPathComponent(path))
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
}
