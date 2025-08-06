//
//  ShoppingListRepository.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.

import Foundation
import SwiftData

/// Protocol defining the interface for shopping list data operations
/// Enables dependency injection and testing with mock implementations
public protocol ShoppingListRepository: Sendable {
    /// Fetch all non-deleted items from storage
    func fetchItems() async throws -> [ShoppingItem]
    
    /// Save or update an item in storage
    func save(item: ShoppingItem) async throws
    
    /// Soft delete an item (mark as deleted for sync purposes)
    func delete(item: ShoppingItem) async throws
    
    /// Fetch items that need synchronization
    func itemsNeedingSync() async throws -> [ShoppingItem]
    
    /// Mark items as successfully synced
    func markItemsAsSynced(_ items: [ShoppingItem]) async throws
    
    /// Update sync status for items
    func updateSyncStatus(_ items: [ShoppingItem], status: SyncStatus) async throws
    
    /// Merge remote items with local items using conflict resolution
    func mergeRemoteItems(_ remoteItems: [ShoppingItem]) async throws
}

