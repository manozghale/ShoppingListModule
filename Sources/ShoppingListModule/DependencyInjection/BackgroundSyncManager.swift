//
//  BackgroundSyncManager.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if os(iOS)
import BackgroundTasks
#endif

/// Background task manager for handling sync operations
/// Integrates with iOS BackgroundTasks framework
public final class BackgroundSyncManager: @unchecked Sendable {
    @MainActor
    public static let shared = BackgroundSyncManager()
    // Must match host app's Info.plist BGTaskSchedulerPermittedIdentifiers entry
    private let backgroundTaskIdentifier = "com.shoppinglist.sync"
    
    private init() {}
    
    /// Register background task with the system
    public func registerBackgroundTasks() {
        #if os(iOS)
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { [weak self] task in
                guard let self = self else { return }
                task.expirationHandler = { }
                // Perform sync without sending the BGTask across actor boundaries
                Task { @MainActor in
                    await self.performBackgroundSync()
                }
                if let refreshTask = task as? BGAppRefreshTask {
                    refreshTask.setTaskCompleted(success: true)
                }
                self.scheduleBackgroundSync()
            }
        }
        #endif
    }
    
    /// Schedule a background sync operation
    public func scheduleBackgroundSync() {
        #if os(iOS)
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
            _ = try? BGTaskScheduler.shared.submit(request)
            return
        }
        #endif
        // Fallback (non-iOS or older OS): simulate with a delayed task
        Task.detached { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await self?.performBackgroundSync()
        }
    }
    
    @MainActor
    private func performBackgroundSync() async {
        guard let syncService = ShoppingListDependencies.shared.resolve(SyncService.self) else {
            return
        }
        
        do {
            try await syncService.synchronize()
            print("Background sync completed successfully")
        } catch {
            print("Background sync failed: \(error)")
            // Optionally schedule retry
            scheduleBackgroundSync()
        }
    }

}

