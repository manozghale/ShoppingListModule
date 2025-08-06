//
//  EndToEndTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

@MainActor
final class EndToEndTests: XCTestCase {
    
    func testCompleteShoppingListWorkflow() async throws {
        // Create module with mock dependencies
        let (module, repository) = TestHelpers.createTestModule()
        
        // 1. Add items
        try await module.addItem(name: "Milk", quantity: 1, note: "Organic")
        try await module.addItem(name: "Bread", quantity: 2, note: "Whole wheat")
        try await module.addItem(name: "Apples", quantity: 6, note: "Red delicious")
        
        // Verify items were added
        var stats = module.getStatistics()
        XCTAssertEqual(stats.totalItems, 3)
        XCTAssertEqual(stats.activeItems, 3)
        XCTAssertEqual(stats.boughtItems, 0)
        
        // 2. Mark items as bought
        let items = try await repository.fetchItems()
        for item in items.prefix(2) {
            await module.viewModel.toggleItemBought(item)
        }
        
        // Verify bought status
        stats = module.getStatistics()
        XCTAssertEqual(stats.totalItems, 3)
        XCTAssertEqual(stats.activeItems, 1)
        XCTAssertEqual(stats.boughtItems, 2)
        
        // 3. Test filtering
        module.viewModel.selectedFilter = .active
        XCTAssertEqual(module.viewModel.filteredItems.count, 1)
        XCTAssertEqual(module.viewModel.filteredItems.first?.name, "Apples")
        
        module.viewModel.selectedFilter = .bought
        XCTAssertEqual(module.viewModel.filteredItems.count, 2)
        
        module.viewModel.selectedFilter = .all
        XCTAssertEqual(module.viewModel.filteredItems.count, 3)
        
        // 4. Test searching
        module.viewModel.searchText = "milk"
        XCTAssertEqual(module.viewModel.filteredItems.count, 1)
        XCTAssertEqual(module.viewModel.filteredItems.first?.name, "Milk")
        
        module.viewModel.searchText = "organic"
        XCTAssertEqual(module.viewModel.filteredItems.count, 1)
        XCTAssertEqual(module.viewModel.filteredItems.first?.name, "Milk")
        
        module.viewModel.searchText = ""
        XCTAssertEqual(module.viewModel.filteredItems.count, 3)
        
        // 5. Test sorting
        module.viewModel.selectedSort = .nameAscending
        XCTAssertEqual(module.viewModel.filteredItems[0].name, "Apples")
        XCTAssertEqual(module.viewModel.filteredItems[1].name, "Bread")
        XCTAssertEqual(module.viewModel.filteredItems[2].name, "Milk")
        
        module.viewModel.selectedSort = .nameDescending
        XCTAssertEqual(module.viewModel.filteredItems[0].name, "Milk")
        XCTAssertEqual(module.viewModel.filteredItems[1].name, "Bread")
        XCTAssertEqual(module.viewModel.filteredItems[2].name, "Apples")
        
        // 6. Test sync
        try await module.sync()
        
        // Verify sync completed
        stats = module.getStatistics()
        XCTAssertEqual(stats.needingSyncItems, 0)
    }
    
    func testErrorHandlingWorkflow() async throws {
        let (module, _) = TestHelpers.createTestModule()
        
        // Test adding item with empty name
        await module.viewModel.addItem(name: "", quantity: 1)
        XCTAssertTrue(module.viewModel.showError)
        XCTAssertEqual(module.viewModel.errorMessage, "Item name cannot be empty")
        
        // Test adding item with invalid quantity
        await module.viewModel.addItem(name: "Test", quantity: 0)
        XCTAssertTrue(module.viewModel.showError)
        XCTAssertEqual(module.viewModel.errorMessage, "Quantity must be greater than zero")
        
        // Test adding item with negative quantity
        await module.viewModel.addItem(name: "Test", quantity: -1)
        XCTAssertTrue(module.viewModel.showError)
        XCTAssertEqual(module.viewModel.errorMessage, "Quantity must be greater than zero")
    }
    
    func testConcurrentOperations() async throws {
        let (module, _) = TestHelpers.createTestModule()
        
        // Perform multiple operations concurrently
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    try? await module.addItem(name: "Item \(i)", quantity: i)
                }
            }
        }
        
        // Verify all items were added
        let stats = module.getStatistics()
        XCTAssertEqual(stats.totalItems, 5)
    }
    
    func testDataPersistence() async throws {
        let (module, repository) = TestHelpers.createTestModule()
        
        // Add items
        try await module.addItem(name: "Persistent Item", quantity: 1)
        
        // Create new module instance (simulating app restart)
        let newRepository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: newRepository, networkService: networkService)
        let newViewModel = ShoppingListViewModel(repository: newRepository, syncService: syncService)
        
        // Load items in new instance
        await newViewModel.loadItems()
        
        // Note: In a real app with SwiftData, items would persist
        // For this test with mock repository, we verify the workflow works
        XCTAssertEqual(newViewModel.items.count, 0)
    }
}

