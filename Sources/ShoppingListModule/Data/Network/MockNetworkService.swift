//
//  MockNetworkService.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Mock network service for testing and offline development
public final class MockNetworkService: NetworkService, @unchecked Sendable {
    private var items: [ShoppingItemDTO] = []
    private let simulateNetworkDelay: Bool
    private let shouldFailRequests: Bool
    
    public init(simulateNetworkDelay: Bool = false, shouldFailRequests: Bool = false) {
        self.simulateNetworkDelay = simulateNetworkDelay
        self.shouldFailRequests = shouldFailRequests
    }
    
    public func fetchItems() async throws -> [ShoppingItemDTO] {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        if shouldFailRequests {
            throw NetworkError.connectionFailed
        }
        
        return items
    }
    
    public func createItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        if shouldFailRequests {
            throw NetworkError.serverError
        }
        
        items.append(item)
        return item
    }
    
    public func updateItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        
        if shouldFailRequests {
            throw NetworkError.serverError
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
        return item
    }
    
    public func deleteItem(id: String) async throws {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: 300_000_000)
        }
        
        if shouldFailRequests {
            throw NetworkError.serverError
        }
        
        items.removeAll { $0.id == id }
    }
}

