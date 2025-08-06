//
//  SyncService.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
@preconcurrency import Combine

/// Protocol defining synchronization operations for shopping list items
/// Enables different sync implementations and testing with mocks
public protocol SyncService: Sendable {
    /// Perform full synchronization (push local changes, pull remote changes)
    func synchronize() async throws
    
    /// Push only local changes to server
    func pushLocalChanges() async throws
    
    /// Pull only remote changes from server
    func pullRemoteChanges() async throws
    
    /// Publisher for sync status updates
    var syncStatusPublisher: AnyPublisher<SyncState, Never> { get }
}

/// Represents the current state of synchronization
public enum SyncState {
    case idle
    case syncing
    case success(itemsProcessed: Int)
    case error(Error)
}

// NetworkService protocol moved to separate file

// DTO moved to separate file

// NetworkError moved to separate file

// Network service implementations moved to separate files

/// Concrete implementation of sync service with robust error handling and retry logic
public final class ShoppingSyncService: SyncService, @unchecked Sendable {
    private let repository: ShoppingListRepository
    private let networkService: NetworkService
    private let syncStatusSubject = PassthroughSubject<SyncState, Never>()
    
    // Retry configuration
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 1.0
    
    public var syncStatusPublisher: AnyPublisher<SyncState, Never> {
        syncStatusSubject.eraseToAnyPublisher()
    }
    
    public init(repository: ShoppingListRepository, networkService: NetworkService) {
        self.repository = repository
        self.networkService = networkService
    }
    
    public func synchronize() async throws {
        syncStatusSubject.send(.syncing)
        
        do {
            // First push local changes, then pull remote changes
            try await pushLocalChanges()
            try await pullRemoteChanges()
            
            syncStatusSubject.send(.success(itemsProcessed: 0)) // Could track actual count
        } catch {
            syncStatusSubject.send(.error(error))
            throw error
        }
    }
    
    public func pushLocalChanges() async throws {
        let itemsToSync = try await repository.itemsNeedingSync()
        guard !itemsToSync.isEmpty else { return }
        
        // Mark items as syncing to prevent concurrent sync attempts
        try await repository.updateSyncStatus(itemsToSync, status: .syncing)
        
        var syncedItems: [ShoppingItem] = []
        var failedItems: [ShoppingItem] = []
        
        for item in itemsToSync {
            do {
                if item.isDeleted {
                    try await retryWithBackoff {
                        try await self.networkService.deleteItem(id: item.id)
                    }
                } else {
                    let dto = ShoppingItemDTO(from: item)
                    
                    // Determine if this is a create or update based on sync history
                    if item.lastSyncedAt == nil {
                        _ = try await retryWithBackoff {
                            try await self.networkService.createItem(dto)
                        }
                    } else {
                        _ = try await retryWithBackoff {
                            try await self.networkService.updateItem(dto)
                        }
                    }
                }
                
                syncedItems.append(item)
            } catch {
                failedItems.append(item)
            }
        }
        
        // Update sync status based on results
        if !syncedItems.isEmpty {
            try await repository.markItemsAsSynced(syncedItems)
        }
        
        if !failedItems.isEmpty {
            try await repository.updateSyncStatus(failedItems, status: .failed)
        }
    }
    
    public func pullRemoteChanges() async throws {
        let remoteItems = try await retryWithBackoff {
            try await self.networkService.fetchItems()
        }
        
        let domainItems = remoteItems.map { $0.toDomainModel() }
        try await repository.mergeRemoteItems(domainItems)
    }
    
    /// Implements exponential backoff retry logic
    private func retryWithBackoff<T>(_ operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry on certain types of errors (like 404, authentication, etc.)
                if !shouldRetry(error) {
                    throw error
                }
                
                if attempt < maxRetries - 1 {
                    // Exponential backoff with jitter
                    let delay = baseDelay * pow(2.0, Double(attempt))
                    let jitter = Double.random(in: 0...0.3) * delay
                    try await Task.sleep(nanoseconds: UInt64((delay + jitter) * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.unknownError
    }
    
    private func shouldRetry(_ error: Error) -> Bool {
        // Only retry on network-related errors, not client errors
        if let networkError = error as? NetworkError {
            switch networkError {
            case .connectionFailed, .serverError, .timeout:
                return true
            case .httpError(let statusCode):
                return statusCode >= 500 // Only retry server errors
            default:
                return false
            }
        }
        return false
    }
}
