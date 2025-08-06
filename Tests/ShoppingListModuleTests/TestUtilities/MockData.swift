//
//  MockData.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
@testable import ShoppingListModule

/// Mock data utilities for testing
public struct MockData {
    
    /// Create sample shopping items for testing
    public static func sampleItems() -> [ShoppingItem] {
        return [
            ShoppingItem(name: "Milk", quantity: 1, note: "Organic if available"),
            ShoppingItem(name: "Bread", quantity: 2, note: "Whole wheat"),
            ShoppingItem(name: "Apples", quantity: 6, note: "Red delicious", isBought: true),
            ShoppingItem(name: "Bananas", quantity: 4, note: "Yellow"),
            ShoppingItem(name: "Chicken", quantity: 1, note: "Breast fillets", isBought: true),
            ShoppingItem(name: "Rice", quantity: 1, note: "Basmati"),
            ShoppingItem(name: "Tomatoes", quantity: 8, note: "Cherry tomatoes"),
            ShoppingItem(name: "Cheese", quantity: 1, note: "Cheddar")
        ]
    }
    
    /// Create items with specific sync statuses for testing
    public static func itemsWithSyncStatuses() -> [ShoppingItem] {
        let items = sampleItems()
        
        // Set different sync statuses
        items[0].syncStatus = .synced
        items[1].syncStatus = .needsSync
        items[2].syncStatus = .syncing
        items[3].syncStatus = .failed
        
        return items
    }
    
    /// Create items for filtering tests
    public static func itemsForFiltering() -> [ShoppingItem] {
        return [
            ShoppingItem(name: "Active Item 1", quantity: 1),
            ShoppingItem(name: "Active Item 2", quantity: 1),
            ShoppingItem(name: "Bought Item 1", quantity: 1, isBought: true),
            ShoppingItem(name: "Bought Item 2", quantity: 1, isBought: true),
            ShoppingItem(name: "Active Item 3", quantity: 1)
        ]
    }
    
    /// Create items for search tests
    public static func itemsForSearching() -> [ShoppingItem] {
        return [
            ShoppingItem(name: "Apple", quantity: 1, note: "Red delicious"),
            ShoppingItem(name: "Banana", quantity: 1, note: "Yellow fruit"),
            ShoppingItem(name: "Orange", quantity: 1, note: "Citrus fruit"),
            ShoppingItem(name: "Grape", quantity: 1, note: "Purple grapes"),
            ShoppingItem(name: "Strawberry", quantity: 1, note: "Red berries")
        ]
    }
    
    /// Create items for sorting tests
    public static func itemsForSorting() -> [ShoppingItem] {
        let now = Date()
        return [
            ShoppingItem(name: "Zebra", quantity: 1, createdAt: now.addingTimeInterval(-300)),
            ShoppingItem(name: "Apple", quantity: 1, createdAt: now.addingTimeInterval(-200)),
            ShoppingItem(name: "Banana", quantity: 1, createdAt: now.addingTimeInterval(-100)),
            ShoppingItem(name: "Cat", quantity: 1, createdAt: now)
        ]
    }
    
    /// Create a single test item
    public static func testItem(name: String = "Test Item", quantity: Int = 1, note: String? = nil, isBought: Bool = false) -> ShoppingItem {
        return ShoppingItem(name: name, quantity: quantity, note: note, isBought: isBought)
    }
}

