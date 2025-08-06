//
//  MockRepository.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Mock repository for testing and development
/// Provides in-memory storage without persistence
public final class MockShoppingListRepository: ShoppingListRepository, @unchecked Sendable {
    private var items: [ShoppingItem] = []
    private let queue = DispatchQueue(label: "mock.repository", qos: .userInitiated)
    
    public init(preloadedItems: [ShoppingItem] = []) {
        self.items = preloadedItems
    }
    
    public func fetchItems() async throws -> [ShoppingItem] {
        return await withCheckedContinuation { continuation in
            queue.async {
                let activeItems = self.items.filter { !$0.isDeleted }
                continuation.resume(returning: activeItems)
            }
        }
    }
    
    public func save(item: ShoppingItem) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                    self.items[index] = item
                } else {
                    self.items.append(item)
                }
                continuation.resume()
            }
        }
    }
    
    public func delete(item: ShoppingItem) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                item.markDeleted()
                continuation.resume()
            }
        }
    }
    
    public func itemsNeedingSync() async throws -> [ShoppingItem] {
        return await withCheckedContinuation { continuation in
            queue.async {
                let needsSync = self.items.filter {
                    $0.syncStatus == .needsSync || $0.syncStatus == .failed
                }
                continuation.resume(returning: needsSync)
            }
        }
    }
    
    public func markItemsAsSynced(_ items: [ShoppingItem]) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                for item in items {
                    item.markSynced()
                }
                continuation.resume()
            }
        }
    }
    
    public func updateSyncStatus(_ items: [ShoppingItem], status: SyncStatus) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                for item in items {
                    item.syncStatus = status
                }
                continuation.resume()
            }
        }
    }
    
    public func mergeRemoteItems(_ remoteItems: [ShoppingItem]) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                for remoteItem in remoteItems {
                    if let existingIndex = self.items.firstIndex(where: { $0.id == remoteItem.id }) {
                        let existingItem = self.items[existingIndex]
                        if remoteItem.modifiedAt > existingItem.modifiedAt {
                            self.items[existingIndex] = remoteItem
                        }
                    } else {
                        self.items.append(remoteItem)
                    }
                }
                continuation.resume()
            }
        }
    }
}

