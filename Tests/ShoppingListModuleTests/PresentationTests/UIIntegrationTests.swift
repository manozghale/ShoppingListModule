//
//  UIIntegrationTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
import SwiftUI
@testable import ShoppingListModule

@MainActor
final class UIIntegrationTests: XCTestCase {
    
    func testShoppingListViewInitialization() {
        let viewModel = ShoppingListViewModel.mock()
        let view = ShoppingListView(viewModel: viewModel)
        
        XCTAssertNotNil(view)
    }
    
    func testShoppingListViewWithItems() {
        let items = MockData.sampleItems()
        let viewModel = ShoppingListViewModel.mock(with: items)
        let view = ShoppingListView(viewModel: viewModel)
        
        XCTAssertNotNil(view)
        XCTAssertEqual(viewModel.items.count, items.count)
    }
    
    func testAddItemSheetInitialization() {
        let viewModel = ShoppingListViewModel.mock()
        let sheet = AddItemSheet(viewModel: viewModel)
        
        XCTAssertNotNil(sheet)
    }
    
    func testEditItemSheetInitialization() {
        let item = MockData.testItem()
        let sheet = EditItemSheet(item: item) { _, _, _ in }
        
        XCTAssertNotNil(sheet)
    }
    
    func testShoppingItemRowInitialization() {
        let item = MockData.testItem()
        let row = ShoppingItemRow(
            item: item,
            onToggleBought: {},
            onEdit: { _, _, _ in }
        )
        
        XCTAssertNotNil(row)
    }
    
    func testSearchAndFilterBarInitialization() {
        let searchText = Binding.constant("")
        let selectedFilter = Binding.constant(ShoppingItemFilter.all)
        let selectedSort = Binding.constant(SortOption.nameAscending)
        let showingFilters = Binding.constant(false)
        
        let bar = SearchAndFilterBar(
            searchText: searchText,
            selectedFilter: selectedFilter,
            selectedSort: selectedSort,
            showingFilters: showingFilters
        )
        
        XCTAssertNotNil(bar)
    }
    
    func testEmptyStateViewInitialization() {
        let view = EmptyStateView(
            filter: .active,
            searchText: "",
            onAddItem: {}
        )
        
        XCTAssertNotNil(view)
    }
    
    func testLoadingViewInitialization() {
        let view = LoadingView()
        
        XCTAssertNotNil(view)
    }
    
    func testSyncStatusIndicator() {
        let indicator = SyncStatusIndicator(status: .needsSync)
        
        XCTAssertNotNil(indicator)
    }
    
    func testFilterChipInitialization() {
        let chip = FilterChip(
            title: "Test",
            isSelected: false
        ) {}
        
        XCTAssertNotNil(chip)
    }
    
    func testShoppingItemsListInitialization() {
        let items = MockData.sampleItems()
        let list = ShoppingItemsList(
            items: items,
            onToggleBought: { _ in },
            onDelete: { _ in },
            onEdit: { _, _, _, _ in }
        )
        
        XCTAssertNotNil(list)
    }
    
    func testSyncStatusButtonInitialization() {
        let button = SyncStatusButton(
            isSyncing: false,
            syncStatus: "Idle",
            hasUnsyncedChanges: false
        ) {}
        
        XCTAssertNotNil(button)
    }
}

