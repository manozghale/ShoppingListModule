//
//  NetworkService.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Protocol defining network operations for shopping list synchronization
/// Enables different network implementations (HTTP, mock, etc.)
public protocol NetworkService: Sendable {
    func fetchItems() async throws -> [ShoppingItemDTO]
    func createItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO
    func updateItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO
    func deleteItem(id: String) async throws
}

/// Data Transfer Object for API communication
/// Separates API representation from domain model
public struct ShoppingItemDTO: Codable {
    public let id: String
    public let name: String
    public let quantity: Int
    public let note: String?
    public let isBought: Bool
    public let createdAt: Date
    public let modifiedAt: Date
    public let isDeleted: Bool
    
    public init(from item: ShoppingItem) {
        self.id = item.id
        self.name = item.name
        self.quantity = item.quantity
        self.note = item.note
        self.isBought = item.isBought
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
        self.isDeleted = item.isDeleted
    }
    
    public func toDomainModel() -> ShoppingItem {
        let item = ShoppingItem(
            id: id,
            name: name,
            quantity: quantity,
            note: note,
            isBought: isBought,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            syncStatus: .synced,
            lastSyncedAt: Date(),
            isDeleted: isDeleted
        )
        return item
    }
}

/// Network-related errors
public enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case connectionFailed
    case serverError
    case timeout
    case httpError(statusCode: Int)
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .connectionFailed:
            return "Connection failed"
        case .serverError:
            return "Server error"
        case .timeout:
            return "Request timed out"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .unknownError:
            return "Unknown network error"
        }
    }
}

