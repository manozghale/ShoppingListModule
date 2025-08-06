//
//  ShoppingItemTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

final class ShoppingItemTests: XCTestCase {
    
    func testShoppingItemInitialization() {
        let item = ShoppingItem(name: "Test Item", quantity: 2, note: "Test note")
        
        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.quantity, 2)
        XCTAssertEqual(item.note, "Test note")
        XCTAssertFalse(item.isBought)
        XCTAssertFalse(item.isDeleted)
        XCTAssertEqual(item.syncStatus, .needsSync)
    }
    
    func testShoppingItemUpdate() {
        let item = ShoppingItem(name: "Original", quantity: 1)
        
        item.update(name: "Updated", quantity: 3, note: "Updated note", isBought: true)
        
        XCTAssertEqual(item.name, "Updated")
        XCTAssertEqual(item.quantity, 3)
        XCTAssertEqual(item.note, "Updated note")
        XCTAssertTrue(item.isBought)
        XCTAssertEqual(item.syncStatus, .needsSync)
    }
    
    func testShoppingItemMarkDeleted() {
        let item = ShoppingItem(name: "Test", quantity: 1)
        
        item.markDeleted()
        
        XCTAssertTrue(item.isDeleted)
        XCTAssertEqual(item.syncStatus, .needsSync)
    }
    
    func testShoppingItemMarkSynced() {
        let item = ShoppingItem(name: "Test", quantity: 1)
        item.syncStatus = .needsSync
        
        item.markSynced()
        
        XCTAssertEqual(item.syncStatus, .synced)
        XCTAssertNotNil(item.lastSyncedAt)
    }
    
    func testShoppingItemSearchMatching() {
        let item = ShoppingItem(name: "Apple", quantity: 1, note: "Red delicious")
        
        XCTAssertTrue(item.matches(searchQuery: "apple"))
        XCTAssertTrue(item.matches(searchQuery: "red"))
        XCTAssertTrue(item.matches(searchQuery: "delicious"))
        XCTAssertFalse(item.matches(searchQuery: "banana"))
    }
    
    func testShoppingItemSearchEmptyQuery() {
        let item = ShoppingItem(name: "Test", quantity: 1)
        
        XCTAssertTrue(item.matches(searchQuery: ""))
        XCTAssertTrue(item.matches(searchQuery: "   "))
    }
}

