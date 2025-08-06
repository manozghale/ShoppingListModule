//
//  ShoppingItem.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import SwiftData

/// Core domain model for a shopping list item
/// Designed to support offline-first architecture with sync capabilities

@Model
public class ShoppingItem: Identifiable, @unchecked Sendable {
    /// Unique identifier - using UUID for distributed system compatibility
    @Attribute(.unique) public var id: String
    
    /// Required name field - primary searchable content
    public var name: String
    
    /// Required quantity field
    public var quantity: Int
    
    /// Optional note field - secondary searchable content
    public var note: String?
    
    /// Purchase status - drives filtering behavior
    public var isBought: Bool
    
    /// Timestamp tracking for sync conflict resolution (last-write-wins)
    public var createdAt: Date
    public var modifiedAt: Date
    
    /// Sync state tracking for offline-first behavior
    public var syncStatus: SyncStatus
    public var lastSyncedAt: Date?
    
    /// Soft delete support for sync scenarios
    public var isDeleted: Bool
    
    public init(id: String = UUID().uuidString, name: String, quantity: Int, note: String? = nil, isBought: Bool = false, createdAt: Date = Date(), modifiedAt: Date = Date(), syncStatus: SyncStatus = .needsSync, lastSyncedAt: Date? = nil, isDeleted: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.syncStatus = syncStatus
        self.lastSyncedAt = lastSyncedAt
        self.isDeleted = isDeleted
    }
    
    /// Update item properties and mark for sync
    public func update(name: String? = nil, quantity: Int? = nil, note: String? = nil, isBought: Bool? = nil) {
        if let name = name { self.name = name }
        if let quantity = quantity { self.quantity = quantity }
        if let note = note { self.note = note }
        if let isBought = isBought { self.isBought = isBought }
            
        self.modifiedAt = Date()
        self.syncStatus = .needsSync
    }
    
    /// Mark item as soft-deleted for sync purposes
    public func markDeleted() {
        self.isDeleted = true
        self.modifiedAt = Date()
        self.syncStatus = .needsSync
    }
        
    /// Mark item as successfully synced
    public func markSynced() {
        self.syncStatus = .synced
        self.lastSyncedAt = Date()
    }
    
    /// Check if item matches search query in name or note
    public func matches(searchQuery: String) -> Bool {
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
            
        let nameMatches = name.lowercased().contains(query)
        let noteMatches = note?.lowercased().contains(query) ?? false
            
        return nameMatches || noteMatches
    }
}

/// Sort options for item display
public enum SortOption: String, CaseIterable {
    case createdDateAscending = "created_asc"
    case createdDateDescending = "created_desc"
    case modifiedDateAscending = "modified_asc"
    case modifiedDateDescending = "modified_desc"
    case nameAscending = "name_asc"
    case nameDescending = "name_desc"
    
    public var displayName: String {
        switch self {
        case .createdDateAscending: return "Created Date ↑"
        case .createdDateDescending: return "Created Date ↓"
        case .modifiedDateAscending: return "Modified Date ↑"
        case .modifiedDateDescending: return "Modified Date ↓"
        case .nameAscending: return "Name A-Z"
        case .nameDescending: return "Name Z-A"
        }
    }
}

extension Array where Element == ShoppingItem {
    /// Apply filter to shopping items array
    public func filtered(by filter: ShoppingItemFilter) -> [ShoppingItem] {
        switch filter {
        case .all:
            return self
        case .active:
            return self.filter { !$0.isBought }
        case .bought:
            return self.filter { $0.isBought }
        }
    }
    
    /// Apply search query to shopping items array
    public func searched(query: String) -> [ShoppingItem] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        return self.filter { $0.matches(searchQuery: query) }
    }
    
    /// Apply sort option to shopping items array
    public func sorted(by option: SortOption) -> [ShoppingItem] {
        switch option {
        case .createdDateAscending:
            return self.sorted { $0.createdAt < $1.createdAt }
        case .createdDateDescending:
            return self.sorted { $0.createdAt > $1.createdAt }
        case .modifiedDateAscending:
            return self.sorted { $0.modifiedAt < $1.modifiedAt }
        case .modifiedDateDescending:
            return self.sorted { $0.modifiedAt > $1.modifiedAt }
        case .nameAscending:
            return self.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return self.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
}
