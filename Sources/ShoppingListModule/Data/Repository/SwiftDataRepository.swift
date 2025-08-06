//
//  SwiftDataRepository.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import SwiftData

/// SwiftData implementation of the repository
/// Provides offline-first local storage with sync support
@MainActor
public class SwiftDataShoppingRepository: ShoppingListRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    /// Convenience initializer for testing and standalone usage
    public convenience init() throws {
        let schema = Schema([ShoppingItem.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        let container = try ModelContainer(for: schema, configurations: [configuration])
        self.init(modelContainer: container)
    }
    
    public func fetchItems() async throws -> [ShoppingItem] {
        let descriptor = FetchDescriptor<ShoppingItem>(
            predicate: #Predicate<ShoppingItem> { item in
                !item.isDeleted
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    public func save(item: ShoppingItem) async throws {
        // Check if this is an existing item by fetching all and filtering
        let allItems = try modelContext.fetch(FetchDescriptor<ShoppingItem>())
        let existingItem = allItems.first { $0.id == item.id }
        
        if existingItem == nil {
            // Insert new item
            modelContext.insert(item)
        }
        // If item exists, SwiftData automatically tracks changes
        
        try modelContext.save()
    }
    
    public func delete(item: ShoppingItem) async throws {
        // Soft delete to support sync
        item.markDeleted()
        try modelContext.save()
    }
    
    public func itemsNeedingSync() async throws -> [ShoppingItem] {
        let descriptor = FetchDescriptor<ShoppingItem>(
            predicate: #Predicate<ShoppingItem> { item in
                item.syncStatus.rawValue == "needs_sync" || item.syncStatus.rawValue == "failed"
            }
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    public func markItemsAsSynced(_ items: [ShoppingItem]) async throws {
        for item in items {
            item.markSynced()
        }
        try modelContext.save()
    }
    
    public func updateSyncStatus(_ items: [ShoppingItem], status: SyncStatus) async throws {
        for item in items {
            item.syncStatus = status
        }
        try modelContext.save()
    }
    
    public func mergeRemoteItems(_ remoteItems: [ShoppingItem]) async throws {
        for remoteItem in remoteItems {
            // Try to find existing local item by fetching all and filtering
            let allItems = try modelContext.fetch(FetchDescriptor<ShoppingItem>())
            let existingItem = allItems.first { $0.id == remoteItem.id }
            
            if let existingItem = existingItem {
                // Apply last-write-wins strategy based on modifiedAt timestamp
                if remoteItem.modifiedAt > existingItem.modifiedAt {
                    // Remote version is newer, update local
                    existingItem.name = remoteItem.name
                    existingItem.quantity = remoteItem.quantity
                    existingItem.note = remoteItem.note
                    existingItem.isBought = remoteItem.isBought
                    existingItem.modifiedAt = remoteItem.modifiedAt
                    existingItem.isDeleted = remoteItem.isDeleted
                    existingItem.markSynced()
                }
                // If local is newer or equal, keep local version
            } else {
                // New item from server
                remoteItem.markSynced()
                modelContext.insert(remoteItem)
            }
        }
        
        try modelContext.save()
    }
}

