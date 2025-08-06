//
//  RepositoryTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

final class RepositoryTests: XCTestCase {
    
    func testMockRepositorySaveAndFetch() async throws {
        let repository = MockShoppingListRepository()
        let item = ShoppingItem(name: "Test Item", quantity: 2, note: "Test note")
        
        try await repository.save(item: item)
        let fetchedItems = try await repository.fetchItems()
        
        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.name, "Test Item")
        XCTAssertEqual(fetchedItems.first?.quantity, 2)
    }
    
    func testMockRepositoryDelete() async throws {
        let repository = MockShoppingListRepository()
        let item = ShoppingItem(name: "Test Item", quantity: 1)
        
        try await repository.save(item: item)
        try await repository.delete(item: item)
        
        let fetchedItems = try await repository.fetchItems()
        XCTAssertEqual(fetchedItems.count, 0)
    }
    
    func testMockRepositoryItemsNeedingSync() async throws {
        let repository = MockShoppingListRepository()
        let item1 = ShoppingItem(name: "Item 1", quantity: 1)
        let item2 = ShoppingItem(name: "Item 2", quantity: 1)
        item2.syncStatus = .synced
        
        try await repository.save(item: item1)
        try await repository.save(item: item2)
        
        let needsSync = try await repository.itemsNeedingSync()
        XCTAssertEqual(needsSync.count, 1)
        XCTAssertEqual(needsSync.first?.name, "Item 1")
    }
    
    func testMockRepositoryMarkItemsAsSynced() async throws {
        let repository = MockShoppingListRepository()
        let item = ShoppingItem(name: "Test Item", quantity: 1)
        item.syncStatus = .needsSync
        
        try await repository.save(item: item)
        try await repository.markItemsAsSynced([item])
        
        let needsSync = try await repository.itemsNeedingSync()
        XCTAssertEqual(needsSync.count, 0)
    }
    
    func testMockRepositoryMergeRemoteItems() async throws {
        let repository = MockShoppingListRepository()
        let localItem = ShoppingItem(name: "Local", quantity: 1)
        let remoteItem = ShoppingItem(name: "Remote", quantity: 2)
        remoteItem.modifiedAt = Date().addingTimeInterval(1000) // Newer timestamp
        
        try await repository.save(item: localItem)
        try await repository.mergeRemoteItems([remoteItem])
        
        let fetchedItems = try await repository.fetchItems()
        XCTAssertEqual(fetchedItems.count, 2) // Both items should exist
    }
}

