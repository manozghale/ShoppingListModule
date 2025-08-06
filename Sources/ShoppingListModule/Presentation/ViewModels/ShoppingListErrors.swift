//
//  ShoppingListErrors.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Domain-specific errors for shopping list operations
public enum ShoppingListError: Error, LocalizedError {
    case emptyName
    case invalidQuantity
    case itemNotFound
    case persistenceError
    
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Item name cannot be empty"
        case .invalidQuantity:
            return "Quantity must be greater than zero"
        case .itemNotFound:
            return "Item not found"
        case .persistenceError:
            return "Failed to save changes"
        }
    }
}

/// Statistics about the shopping list state
public struct ShoppingListStatistics {
    public let totalItems: Int
    public let activeItems: Int
    public let boughtItems: Int
    public let needingSyncItems: Int
    
    public var hasUnsyncedChanges: Bool {
        needingSyncItems > 0
    }
    
    public init(totalItems: Int, activeItems: Int, boughtItems: Int, needingSyncItems: Int) {
        self.totalItems = totalItems
        self.activeItems = activeItems
        self.boughtItems = boughtItems
        self.needingSyncItems = needingSyncItems
    }
}

