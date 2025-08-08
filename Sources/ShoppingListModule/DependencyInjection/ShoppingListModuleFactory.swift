//
//  ShoppingListModuleFactory.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Factory class responsible for creating and configuring the shopping list module
/// This is the main entry point for integrating the module into a host application
public class ShoppingListModuleFactory {
    
    /// Create a fully configured shopping list view
    /// This is the primary integration method for host applications
    @MainActor
    public static func createShoppingListView(
        configuration: ShoppingListConfiguration = .production
    ) async throws -> ShoppingListView {
        
        // Setup dependencies based on configuration
        try await setupDependencies(configuration: configuration)
        
        // Create ViewModel with injected dependencies
        let viewModel = try await createViewModel(configuration: configuration)
        
        return ShoppingListView(viewModel: viewModel)
    }
    
    /// Create a view model for custom UI implementations
    @MainActor
    public static func createViewModel(
        configuration: ShoppingListConfiguration = .production
    ) async throws -> ShoppingListViewModel {
        
        // Setup dependencies based on configuration
        try await setupDependencies(configuration: configuration)
        
        guard let repository = ShoppingListDependencies.shared.resolve(ShoppingListRepository.self) else {
            throw ModuleError.missingDependency("ShoppingListRepository")
        }
        
        guard let syncService = ShoppingListDependencies.shared.resolve(SyncService.self) else {
            throw ModuleError.missingDependency("SyncService")
        }
        
        return ShoppingListViewModel(repository: repository, syncService: syncService)
    }
    
    /// Setup all required dependencies based on configuration
    @MainActor
    private static func setupDependencies(configuration: ShoppingListConfiguration) async throws {
        let container = ShoppingListDependencies.shared
        
        // Setup Repository
        let repository: ShoppingListRepository
        if configuration.isTestMode {
            repository = MockShoppingListRepository()
        } else {
            repository = try await SwiftDataShoppingRepository()
        }
        container.register(repository, for: ShoppingListRepository.self)
        
        // Setup Network Service
        let networkService: NetworkService
        if let apiURL = configuration.apiBaseURL {
            networkService = HTTPShoppingNetworkService(baseURL: apiURL)
        } else {
            networkService = MockNetworkService()
        }
        container.register(networkService, for: NetworkService.self)
        
        // Setup Sync Service
        let syncService = ShoppingSyncService(
            repository: repository,
            networkService: networkService
        )
        container.register(syncService, for: SyncService.self)
    }
    
    /// Create a minimal module for SwiftUI previews
    @MainActor
    public static func preview() async -> ShoppingListView {
        do {
            return try await createShoppingListView(configuration: .development)
        } catch {
            // Fallback for preview failures
            return ShoppingListView(viewModel: .preview)
        }
    }
    
    /// Helper method for UIKit integration
    /// Returns a UIViewController wrapping the SwiftUI view
    #if canImport(UIKit)
    @MainActor
    public static func createViewController(
        configuration: ShoppingListConfiguration = .production
    ) async throws -> UIViewController {
        let swiftUIView = try await createShoppingListView(configuration: configuration)
        return UIHostingController(rootView: swiftUIView)
    }
    
    /// Helper method for AppDelegate/SceneDelegate integration
    @MainActor
    public static func setupModule(
        in application: UIApplication,
        configuration: ShoppingListConfiguration = .production
    ) async throws {
        try await setupDependencies(configuration: configuration)
        
        if configuration.enableBackgroundSync {
            BackgroundSyncManager.shared.registerBackgroundTasks()
        }
    }
    #endif
}

/// Errors that can occur during module creation and configuration
public enum ModuleError: Error, LocalizedError {
    case missingDependency(String)
    case configurationError(String)
    case initializationFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .missingDependency(let dependency):
            return "Missing required dependency: \(dependency)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .initializationFailed(let error):
            return "Module initialization failed: \(error.localizedDescription)"
        }
    }
}

#if DEBUG
extension ShoppingListModuleFactory {
    /// Create a module configured for unit testing
    @MainActor
    public static func testing(
        with mockItems: [ShoppingItem] = []
    ) -> (viewModel: ShoppingListViewModel, repository: MockShoppingListRepository) {
        
        let mockRepository = MockShoppingListRepository(preloadedItems: mockItems)
        let mockNetworkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: mockRepository, networkService: mockNetworkService)
        
        // Register test dependencies
        let container = ShoppingListDependencies.shared
        container.register(mockRepository, for: ShoppingListRepository.self)
        container.register(mockNetworkService, for: NetworkService.self)
        container.register(syncService, for: SyncService.self)
        
        let viewModel = ShoppingListViewModel(repository: mockRepository, syncService: syncService)
        return (viewModel, mockRepository)
    }
}
#endif

