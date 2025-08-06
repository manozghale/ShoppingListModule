//
//  ShoppingItemRow.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI

/// Individual row view for a shopping item
public struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggleBought: () -> Void
    let onEdit: (String, Int, String?) -> Void
    
    @State private var showingEditSheet = false
    
    public init(item: ShoppingItem, onToggleBought: @escaping () -> Void, onEdit: @escaping (String, Int, String?) -> Void) {
        self.item = item
        self.onToggleBought = onToggleBought
        self.onEdit = onEdit
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Bought checkbox
            Button(action: onToggleBought) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isBought ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(item.isBought ? .secondary : .primary)
                    .strikethrough(item.isBought)
                
                HStack {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let note = item.note {
                        Text("• \(note)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            
            Spacer()
            
            // Sync status indicator
            if item.syncStatus != .synced {
                SyncStatusIndicator(status: item.syncStatus)
            }
            
            // Edit button
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggleBought()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemSheet(item: item, onSave: onEdit)
        }
    }
}

/// Sync status indicator component
public struct SyncStatusIndicator: View {
    let status: SyncStatus
    
    public init(status: SyncStatus) {
        self.status = status
    }
    
    public var body: some View {
        Group {
            switch status {
            case .synced:
                EmptyView()
            case .needsSync:
                Image(systemName: "arrow.up.circle")
                    .foregroundColor(.orange)
            case .syncing:
                ProgressView()
                    .scaleEffect(0.7)
            case .failed:
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
        }
        .font(.caption)
    }
}

