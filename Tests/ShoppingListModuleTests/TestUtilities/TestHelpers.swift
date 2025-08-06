//
//  TestHelpers.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import XCTest
@testable import ShoppingListModule

/// Test helper utilities
public struct TestHelpers {
    
    /// Wait for a condition to be true with timeout
    public static func waitForCondition(
        timeout: TimeInterval = 5.0,
        condition: @escaping () -> Bool
    ) async {
        let startTime = Date()
        
        while !condition() && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if !condition() {
            XCTFail("Condition not met within timeout")
        }
    }
    
    /// Create a test ViewModel with mock dependencies
    public static func createTestViewModel(
        with items: [ShoppingItem] = []
    ) -> (viewModel: ShoppingListViewModel, repository: MockShoppingListRepository) {
        let repository = MockShoppingListRepository(preloadedItems: items)
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        let viewModel = ShoppingListViewModel(repository: repository, syncService: syncService)
        
        return (viewModel, repository)
    }
    
    /// Create a test module with mock dependencies
    public static func createTestModule(
        with items: [ShoppingItem] = []
    ) -> (module: ShoppingListModule, repository: MockShoppingListRepository) {
        let repository = MockShoppingListRepository(preloadedItems: items)
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        // Register test dependencies
        let container = ShoppingListDependencies.shared
        container.register(repository, for: ShoppingListRepository.self)
        container.register(networkService, for: NetworkService.self)
        container.register(syncService, for: SyncService.self)
        
        do {
            let module = try ShoppingListModule(configuration: .development)
            return (module, repository)
        } catch {
            fatalError("Failed to create test module: \(error)")
        }
    }
    
    /// Assert that two arrays contain the same items (order doesn't matter)
    public static func assertArraysContainSameItems<T: Equatable>(
        _ array1: [T],
        _ array2: [T],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(array1.count, array2.count, "Arrays have different counts", file: file, line: line)
        
        for item in array1 {
            XCTAssertTrue(array2.contains(item), "Array2 does not contain item: \(item)", file: file, line: line)
        }
    }
    
    /// Assert that a shopping item has expected properties
    public static func assertShoppingItem(
        _ item: ShoppingItem,
        name: String,
        quantity: Int,
        note: String? = nil,
        isBought: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(item.name, name, "Item name mismatch", file: file, line: line)
        XCTAssertEqual(item.quantity, quantity, "Item quantity mismatch", file: file, line: line)
        XCTAssertEqual(item.note, note, "Item note mismatch", file: file, line: line)
        XCTAssertEqual(item.isBought, isBought, "Item bought status mismatch", file: file, line: line)
    }
    
    /// Create a test expectation that can be fulfilled asynchronously
    public static func createAsyncExpectation(
        description: String,
        timeout: TimeInterval = 5.0
    ) -> XCTestExpectation {
        return XCTestExpectation(description: description)
    }
}

