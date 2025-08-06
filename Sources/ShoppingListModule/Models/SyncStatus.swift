//
//  SyncStatus.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Represents the synchronization status of a shopping item
/// Used for offline-first architecture with conflict resolution
public enum SyncStatus: String, Codable, CaseIterable, Sendable {
    case synced = "synced"
    case needsSync = "needs_sync"
    case syncing = "syncing"
    case failed = "failed"
    
    public var displayName: String {
        switch self {
        case .synced:
            return "Synced"
        case .needsSync:
            return "Needs Sync"
        case .syncing:
            return "Syncing"
        case .failed:
            return "Failed"
        }
    }
    
    public var isPending: Bool {
        switch self {
        case .needsSync, .syncing:
            return true
        case .synced, .failed:
            return false
        }
    }
}

