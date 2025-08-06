//
//  EmptyStateView.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI

/// Empty state view shown when no items match the current filter/search
public struct EmptyStateView: View {
    let filter: ShoppingItemFilter
    let searchText: String
    let onAddItem: () -> Void
    
    public init(filter: ShoppingItemFilter, searchText: String, onAddItem: @escaping () -> Void) {
        self.filter = filter
        self.searchText = searchText
        self.onAddItem = onAddItem
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "cart" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                if searchText.isEmpty {
                    Text(emptyStateTitle)
                        .font(.headline)
                    
                    Text(emptyStateMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No items found")
                        .font(.headline)
                    
                    Text("Try adjusting your search or filter")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            if searchText.isEmpty && filter == .active {
                Button("Add First Item", action: onAddItem)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private var emptyStateTitle: String {
        switch filter {
        case .all:
            return "No Items Yet"
        case .active:
            return "All Done!"
        case .bought:
            return "No Bought Items"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "Start building your shopping list by adding your first item."
        case .active:
            return "You've completed all your shopping! Great job."
        case .bought:
            return "Items you mark as bought will appear here."
        }
    }
}

