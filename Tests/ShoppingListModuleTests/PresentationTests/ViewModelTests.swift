//
//  ViewModelTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

@MainActor
final class ViewModelTests: XCTestCase {
    
    var viewModel: ShoppingListViewModel!
    var mockRepository: MockShoppingListRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: mockRepository, networkService: networkService)
        viewModel = ShoppingListViewModel(repository: mockRepository, syncService: syncService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testViewModelInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.items.count, 0)
        XCTAssertEqual(viewModel.filteredItems.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isSyncing)
    }
    
    func testAddItem() async {
        await viewModel.addItem(name: "Test Item", quantity: 2, note: "Test note")
        
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.name, "Test Item")
        XCTAssertEqual(viewModel.items.first?.quantity, 2)
        XCTAssertEqual(viewModel.items.first?.note, "Test note")
    }
    
    func testAddItemWithEmptyName() async {
        await viewModel.addItem(name: "", quantity: 1)
        
        XCTAssertEqual(viewModel.items.count, 0)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Item name cannot be empty")
    }
    
    func testAddItemWithInvalidQuantity() async {
        await viewModel.addItem(name: "Test", quantity: 0)
        
        XCTAssertEqual(viewModel.items.count, 0)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Quantity must be greater than zero")
    }
    
    func testUpdateItem() async {
        let item = ShoppingItem(name: "Original", quantity: 1)
        try? await mockRepository.save(item: item)
        await viewModel.loadItems()
        
        await viewModel.updateItem(item, name: "Updated", quantity: 3, note: "Updated note")
        
        XCTAssertEqual(viewModel.items.first?.name, "Updated")
        XCTAssertEqual(viewModel.items.first?.quantity, 3)
        XCTAssertEqual(viewModel.items.first?.note, "Updated note")
    }
    
    func testToggleItemBought() async {
        let item = ShoppingItem(name: "Test", quantity: 1)
        try? await mockRepository.save(item: item)
        await viewModel.loadItems()
        
        await viewModel.toggleItemBought(item)
        
        XCTAssertTrue(viewModel.items.first?.isBought ?? false)
    }
    
    func testDeleteItem() async {
        let item = ShoppingItem(name: "Test", quantity: 1)
        try? await mockRepository.save(item: item)
        await viewModel.loadItems()
        
        await viewModel.deleteItem(item)
        
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testFiltering() async {
        let item1 = ShoppingItem(name: "Active", quantity: 1)
        let item2 = ShoppingItem(name: "Bought", quantity: 1, isBought: true)
        
        try? await mockRepository.save(item: item1)
        try? await mockRepository.save(item: item2)
        await viewModel.loadItems()
        
        // Test active filter
        viewModel.selectedFilter = .active
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Active")
        
        // Test bought filter
        viewModel.selectedFilter = .bought
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Bought")
        
        // Test all filter
        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredItems.count, 2)
    }
    
    func testSearching() async {
        let item1 = ShoppingItem(name: "Apple", quantity: 1, note: "Red delicious")
        let item2 = ShoppingItem(name: "Banana", quantity: 1, note: "Yellow")
        
        try? await mockRepository.save(item: item1)
        try? await mockRepository.save(item: item2)
        await viewModel.loadItems()
        
        viewModel.searchText = "apple"
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Apple")
        
        viewModel.searchText = "red"
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Apple")
        
        viewModel.searchText = "yellow"
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Banana")
    }
    
    func testSorting() async {
        let item1 = ShoppingItem(name: "Zebra", quantity: 1)
        let item2 = ShoppingItem(name: "Apple", quantity: 1)
        
        try? await mockRepository.save(item: item1)
        try? await mockRepository.save(item: item2)
        await viewModel.loadItems()
        
        viewModel.selectedSort = .nameAscending
        XCTAssertEqual(viewModel.filteredItems[0].name, "Apple")
        XCTAssertEqual(viewModel.filteredItems[1].name, "Zebra")
        
        viewModel.selectedSort = .nameDescending
        XCTAssertEqual(viewModel.filteredItems[0].name, "Zebra")
        XCTAssertEqual(viewModel.filteredItems[1].name, "Apple")
    }
    
    func testStatistics() async {
        let item1 = ShoppingItem(name: "Active", quantity: 1)
        let item2 = ShoppingItem(name: "Bought", quantity: 1, isBought: true)
        let item3 = ShoppingItem(name: "Needs Sync", quantity: 1)
        item3.syncStatus = .needsSync
        
        try? await mockRepository.save(item: item1)
        try? await mockRepository.save(item: item2)
        try? await mockRepository.save(item: item3)
        await viewModel.loadItems()
        
        let stats = viewModel.statistics
        XCTAssertEqual(stats.totalItems, 3)
        XCTAssertEqual(stats.activeItems, 2)
        XCTAssertEqual(stats.boughtItems, 1)
        XCTAssertEqual(stats.needingSyncItems, 1)
        XCTAssertTrue(stats.hasUnsyncedChanges)
    }
}

