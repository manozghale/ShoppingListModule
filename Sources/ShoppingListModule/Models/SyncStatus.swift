//
//  SyncStatus.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Represents the synchronization status of a shopping item
/// Used for offline-first architecture with conflict resolution
/// Note: This enum is designed to work with SwiftData and must maintain
/// the exact raw values for database compatibility
public enum SyncStatus: String, Codable, CaseIterable, Sendable, Hashable {
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
    
    /// Whether the item is currently being processed
    public var isProcessing: Bool {
        self == .syncing
    }
    
    /// Whether the item needs attention (failed or needs sync)
    public var needsAttention: Bool {
        self == .needsSync || self == .failed
    }
}

