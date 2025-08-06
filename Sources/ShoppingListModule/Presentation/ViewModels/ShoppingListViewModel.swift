//
//  ShoppingListViewModel.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//
import Foundation
import Combine
import SwiftUI

/// ViewModel for the shopping list feature
/// Implements MVVM pattern with reactive data binding
@MainActor
public class ShoppingListViewModel: ObservableObject {
    // MARK: - Published Properties (UI State)
    
    @Published public var items: [ShoppingItem] = []
    @Published public var filteredItems: [ShoppingItem] = []
    @Published public var searchText: String = "" {
        didSet { applyFiltersAndSearch() }
    }
    @Published public var selectedFilter: ShoppingItemFilter = .active {
        didSet { applyFiltersAndSearch() }
    }
    @Published public var selectedSort: SortOption = .modifiedDateDescending {
        didSet { applyFiltersAndSearch() }
    }
    
    // Loading and sync states
    @Published public var isLoading: Bool = false
    @Published public var isSyncing: Bool = false
    @Published public var syncStatus: String = ""
    
    // Error handling
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ShoppingListRepository
    private let syncService: SyncService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(repository: ShoppingListRepository, syncService: SyncService) {
        self.repository = repository
        self.syncService = syncService
        
        setupSyncStatusObserver()
        
        // Load initial data
        Task {
            await loadItems()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load all items from repository
    public func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loadedItems = try await repository.fetchItems()
            items = loadedItems
            applyFiltersAndSearch()
        } catch {
            handleError(error)
        }
    }
    
    /// Add a new shopping item
    public func addItem(name: String, quantity: Int, note: String?) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            handleError(ShoppingListError.emptyName)
            return
        }
        
        guard quantity > 0 else {
            handleError(ShoppingListError.invalidQuantity)
            return
        }
        
        let newItem = ShoppingItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : note?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        do {
            try await repository.save(item: newItem)
            await loadItems()
            
            // Trigger background sync
            triggerBackgroundSync()
        } catch {
            handleError(error)
        }
    }
    
    /// Update an existing item
    public func updateItem(_ item: ShoppingItem, name: String? = nil, quantity: Int? = nil, note: String? = nil, isBought: Bool? = nil) async {
        // Validate inputs
        if let name = name, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            handleError(ShoppingListError.emptyName)
            return
        }
        
        if let quantity = quantity, quantity <= 0 {
            handleError(ShoppingListError.invalidQuantity)
            return
        }
        
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote?.isEmpty == true ? nil : trimmedNote
        
        item.update(name: trimmedName, quantity: quantity, note: finalNote, isBought: isBought)
        
        do {
            try await repository.save(item: item)
            await loadItems()
            
            triggerBackgroundSync()
        } catch {
            handleError(error)
        }
    }
    
    /// Toggle the bought status of an item
    public func toggleItemBought(_ item: ShoppingItem) async {
        await updateItem(item, isBought: !item.isBought)
    }
    
    /// Delete an item
    public func deleteItem(_ item: ShoppingItem) async {
        do {
            try await repository.delete(item: item)
            await loadItems()
            
            triggerBackgroundSync()
        } catch {
            handleError(error)
        }
    }
    
    /// Manually trigger synchronization
    public func sync() async {
        guard !isSyncing else { return }
        
        do {
            try await syncService.synchronize()
            await loadItems()
        } catch {
            handleError(error)
        }
    }
    
    /// Clear completed (bought) items
    public func clearBoughtItems() async {
        let boughtItems = items.filter { $0.isBought }
        
        for item in boughtItems {
            await deleteItem(item)
        }
    }
    
    /// Get statistics about the shopping list
    public var statistics: ShoppingListStatistics {
        ShoppingListStatistics(
            totalItems: items.count,
            activeItems: items.filter { !$0.isBought }.count,
            boughtItems: items.filter { $0.isBought }.count,
            needingSyncItems: items.filter { $0.syncStatus == .needsSync || $0.syncStatus == .failed }.count
        )
    }
    
    // MARK: - Private Methods
    
    private func applyFiltersAndSearch() {
        var result = items
        
        // Apply filter
        result = result.filtered(by: selectedFilter)
        
        // Apply search
        result = result.searched(query: searchText)
        
        // Apply sort
        result = result.sorted(by: selectedSort)
        
        filteredItems = result
    }
    
    private func setupSyncStatusObserver() {
        syncService.syncStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    self.isSyncing = false
                    self.syncStatus = "Sync complete"
                    
                case .syncing:
                    self.isSyncing = true
                    self.syncStatus = "Syncing..."
                    
                case .success(let itemsProcessed):
                    self.isSyncing = false
                    self.syncStatus = itemsProcessed > 0 ? "Synced \(itemsProcessed) items" : "Up to date"
                    
                case .error(let error):
                    self.isSyncing = false
                    self.syncStatus = "Sync failed"
                    self.handleError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func triggerBackgroundSync() {
        // Trigger sync without blocking UI
        Task.detached {
            try? await self.syncService.synchronize()
        }
    }
    
    private func handleError(_ error: Error) {
        let message: String
        
        if let shoppingError = error as? ShoppingListError {
            message = shoppingError.localizedDescription
        } else if let networkError = error as? NetworkError {
            message = networkError.localizedDescription
        } else {
            message = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        errorMessage = message
        showError = true
        
        // Auto-dismiss error after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            errorMessage = nil
            showError = false
        }
    }
}

// MARK: - Convenience Extensions

extension ShoppingListViewModel {
    /// Create a view model configured for production use
    public static func production() throws -> ShoppingListViewModel {
        let repository = try SwiftDataShoppingRepository()
        
        // In a real app, this URL would come from configuration
        let networkService = MockNetworkService() // Replace with HTTPShoppingNetworkService for real API
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        return ShoppingListViewModel(repository: repository, syncService: syncService)
    }
    
    /// Create a view model configured for testing with mock data
    public static func mock(with items: [ShoppingItem] = []) -> ShoppingListViewModel {
        let repository = MockShoppingListRepository(preloadedItems: items)
        let networkService = MockNetworkService()
        let syncService = ShoppingSyncService(repository: repository, networkService: networkService)
        
        return ShoppingListViewModel(repository: repository, syncService: syncService)
    }
}

/// Preview data for SwiftUI previews and testing
extension ShoppingListViewModel {
    public static var preview: ShoppingListViewModel {
        let sampleItems = [
            ShoppingItem(name: "Milk", quantity: 1, note: "Organic if available"),
            ShoppingItem(name: "Bread", quantity: 2, note: nil),
            ShoppingItem(name: "Apples", quantity: 6, note: "Red delicious", isBought: true)
        ]
        
        return .mock(with: sampleItems)
    }
}
