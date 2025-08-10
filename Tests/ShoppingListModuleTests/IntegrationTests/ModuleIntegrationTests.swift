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
    
    func testFactoryCreatesViewModel() async throws {
        let vm = try await ShoppingListModuleFactory.createViewModel(configuration: .development)
        XCTAssertNotNil(vm)
    }
    
    func testViewControllerFactoryAvailability() async throws {
        #if canImport(UIKit)
        let vc = try await ShoppingListModuleFactory.createViewController(configuration: .development)
        XCTAssertNotNil(vc)
        #else
        throw XCTSkip("UIKit unavailable")
        #endif
    }
    
    func testCreateViewAsync() async throws {
        let view = try await ShoppingListModuleFactory.createShoppingListView(configuration: .development)
        XCTAssertNotNil(view)
    }
    
    // Other DI tests remain
    
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

