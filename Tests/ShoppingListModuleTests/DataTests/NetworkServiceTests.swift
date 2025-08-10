//
//  NetworkServiceTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

final class NetworkServiceTests: XCTestCase {
    
    func testMockNetworkServiceFetchItems() async throws {
        let networkService = MockNetworkService()
        
        let items = try await networkService.fetchItems()
        XCTAssertEqual(items.count, 0)
    }
    
    func testMockNetworkServiceCreateItem() async throws {
        let networkService = MockNetworkService()
        let item = ShoppingItemDTO(from: ShoppingItem(name: "Test", quantity: 1))
        
        let createdItem = try await networkService.createItem(item)
        XCTAssertEqual(createdItem.name, "Test")
        XCTAssertEqual(createdItem.quantity, 1)
        
        let fetchedItems = try await networkService.fetchItems()
        XCTAssertEqual(fetchedItems.count, 1)
    }
    
    func testMockNetworkServiceUpdateItem() async throws {
        let networkService = MockNetworkService()
        let item = ShoppingItemDTO(from: ShoppingItem(name: "Original", quantity: 1))
        
        let createdItem = try await networkService.createItem(item)
        // Build an updated DTO with the same id
        let updatedDomain = ShoppingItem(id: createdItem.id, name: "Updated", quantity: 2)
        let updatedItem = ShoppingItemDTO(from: updatedDomain)
        let result = try await networkService.updateItem(updatedItem)
        XCTAssertEqual(result.name, "Updated")
        XCTAssertEqual(result.quantity, 2)
    }
    
    func testMockNetworkServiceDeleteItem() async throws {
        let networkService = MockNetworkService()
        let item = ShoppingItemDTO(from: ShoppingItem(name: "Test", quantity: 1))
        
        let createdItem = try await networkService.createItem(item)
        try await networkService.deleteItem(id: createdItem.id)
        
        let fetchedItems = try await networkService.fetchItems()
        XCTAssertEqual(fetchedItems.count, 0)
    }
    
    func testMockNetworkServiceWithDelay() async throws {
        let networkService = MockNetworkService(simulateNetworkDelay: true)
        let startTime = Date()
        
        _ = try await networkService.fetchItems()
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThan(elapsedTime, 0.9) // Should take at least 0.9 seconds
    }
    
    func testMockNetworkServiceWithFailure() async throws {
        let networkService = MockNetworkService(shouldFailRequests: true)
        
        do {
            _ = try await networkService.fetchItems()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testShoppingItemDTOConversion() {
        let originalItem = ShoppingItem(name: "Test", quantity: 2, note: "Note", isBought: true)
        let dto = ShoppingItemDTO(from: originalItem)
        let convertedItem = dto.toDomainModel()
        
        XCTAssertEqual(originalItem.id, convertedItem.id)
        XCTAssertEqual(originalItem.name, convertedItem.name)
        XCTAssertEqual(originalItem.quantity, convertedItem.quantity)
        XCTAssertEqual(originalItem.note, convertedItem.note)
        XCTAssertEqual(originalItem.isBought, convertedItem.isBought)
        XCTAssertEqual(convertedItem.syncStatus, .synced)
    }
}

