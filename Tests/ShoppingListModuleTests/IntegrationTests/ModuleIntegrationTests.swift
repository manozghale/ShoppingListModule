//
//  ModuleIntegrationTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

@MainActor
final class ModuleIntegrationTests: XCTestCase {
    
    func testModuleCreation() async throws {
        let module = try ShoppingListModule(configuration: .development)
        
        XCTAssertNotNil(module)
        XCTAssertNotNil(module.view)
        XCTAssertNotNil(module.viewModel)
    }
    
    func testModuleAddItem() async throws {
        let module = try ShoppingListModule(configuration: .development)
        
        try await module.addItem(name: "Test Item", quantity: 2, note: "Test note")
        
        let stats = module.getStatistics()
        XCTAssertEqual(stats.totalItems, 1)
        XCTAssertEqual(stats.activeItems, 1)
        XCTAssertEqual(stats.boughtItems, 0)
    }
    
    func testModuleSync() async throws {
        let module = try ShoppingListModule(configuration: .development)
        
        // Add an item
        try await module.addItem(name: "Test Item", quantity: 1)
        
        // Sync should not throw
        try await module.sync()
        
        let stats = module.getStatistics()
        XCTAssertEqual(stats.needingSyncItems, 0)
    }
    
    func testModuleFactoryCreation() async throws {
        let view = try ShoppingListModuleFactory.createShoppingListView(configuration: .development)
        
        XCTAssertNotNil(view)
    }
    
    func testModuleFactoryViewModelCreation() async throws {
        let viewModel = try ShoppingListModuleFactory.createViewModel(configuration: .development)
        
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testModuleFactoryViewControllerCreation() async throws {
        let viewController = try ShoppingListModuleFactory.createViewController(configuration: .development)
        
        XCTAssertNotNil(viewController)
        XCTAssertTrue(viewController is UIHostingController<ShoppingListView>)
    }
    
    func testDependencyInjection() async throws {
        let container = ShoppingListDependencies.shared
        container.reset()
        
        // Setup dependencies
        let repository = MockShoppingListRepository()
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        container.register(repository, for: ShoppingListRepository.self)
        container.register(networkService, for: NetworkService.self)
        container.register(syncService, for: SyncService.self)
        
        // Verify dependencies can be resolved
        XCTAssertNotNil(container.resolve(ShoppingListRepository.self))
        XCTAssertNotNil(container.resolve(NetworkService.self))
        XCTAssertNotNil(container.resolve(SyncService.self))
    }
    
    func testConfigurationPresets() {
        let productionConfig = ShoppingListConfiguration.production
        let developmentConfig = ShoppingListConfiguration.development
        
        XCTAssertTrue(productionConfig.enableBackgroundSync)
        XCTAssertFalse(developmentConfig.enableBackgroundSync)
        XCTAssertTrue(developmentConfig.isTestMode)
        XCTAssertFalse(productionConfig.isTestMode)
    }
}

