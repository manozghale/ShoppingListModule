//
//  HTTPNetworkService.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Real network service implementation with retry logic and error handling
public final class HTTPShoppingNetworkService: NetworkService, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // Configure date formatting to match API expectations
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self.encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    public func fetchItems() async throws -> [ShoppingItemDTO] {
        let url = baseURL.appendingPathComponent("items")
        let (data, response) = try await session.data(from: url)
        
        try validateResponse(response)
        return try decoder.decode([ShoppingItemDTO].self, from: data)
    }
    
    public func createItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO {
        let url = baseURL.appendingPathComponent("items")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(item)
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(ShoppingItemDTO.self, from: data)
    }
    
    public func updateItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO {
        let url = baseURL.appendingPathComponent("items/\(item.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(item)
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(ShoppingItemDTO.self, from: data)
    }
    
    public func deleteItem(id: String) async throws {
        let url = baseURL.appendingPathComponent("items/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

