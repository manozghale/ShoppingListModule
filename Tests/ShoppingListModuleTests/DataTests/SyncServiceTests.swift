//
//  SyncServiceTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
import Combine
@testable import ShoppingListModule

final class SyncServiceTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testSyncServiceInitialization() {
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        XCTAssertNotNil(syncService)
    }
    
    func testSyncServiceStatusPublisher() async {
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        let expectation = XCTestExpectation(description: "Sync status update")
        
        syncService.syncStatusPublisher
            .sink { status in
                switch status {
                case .idle:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testSyncServicePushLocalChanges() async throws {
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        // Add an item that needs sync
        let item = ShoppingItem(name: "Test", quantity: 1)
        item.syncStatus = .needsSync
        try await repository.save(item: item)
        
        // Push changes
        try await syncService.pushLocalChanges()
        
        // Verify item was synced
        let needsSync = try await repository.itemsNeedingSync()
        XCTAssertEqual(needsSync.count, 0)
    }
    
    func testSyncServicePullRemoteChanges() async throws {
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        // Add a remote item
        let remoteItem = ShoppingItem(name: "Remote", quantity: 2)
        let dto = ShoppingItemDTO(from: remoteItem)
        _ = try await networkService.createItem(dto)
        
        // Pull changes
        try await syncService.pullRemoteChanges()
        
        // Verify item was merged
        let items = try await repository.fetchItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Remote")
    }
    
    func testSyncServiceFullSynchronization() async throws {
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        // Add local item
        let localItem = ShoppingItem(name: "Local", quantity: 1)
        localItem.syncStatus = .needsSync
        try await repository.save(localItem)
        
        // Add remote item
        let remoteItem = ShoppingItem(name: "Remote", quantity: 2)
        let dto = ShoppingItemDTO(from: remoteItem)
        _ = try await networkService.createItem(dto)
        
        // Full sync
        try await syncService.synchronize()
        
        // Verify both items exist and local item is synced
        let items = try await repository.fetchItems()
        XCTAssertEqual(items.count, 2)
        
        let needsSync = try await repository.itemsNeedingSync()
        XCTAssertEqual(needsSync.count, 0)
    }
}

