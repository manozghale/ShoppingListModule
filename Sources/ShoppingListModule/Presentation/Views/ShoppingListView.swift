//
//  ShoppingListView.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI
import Combine

// MARK: - Main Shopping List View

/// Main shopping list interface - the primary entry point for the module
public struct ShoppingListView: View {
    @StateObject private var viewModel: ShoppingListViewModel
    @State private var showingAddSheet = false
    @State private var showingFilters = false
    
    public init(viewModel: ShoppingListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                SearchAndFilterBar(
                    searchText: $viewModel.searchText,
                    selectedFilter: $viewModel.selectedFilter,
                    selectedSort: $viewModel.selectedSort,
                    showingFilters: $showingFilters
                )
                
                // Main content
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.filteredItems.isEmpty {
                    EmptyStateView(
                        filter: viewModel.selectedFilter,
                        searchText: viewModel.searchText,
                        onAddItem: { showingAddSheet = true }
                    )
                } else {
                    ShoppingItemsList(
                        items: viewModel.filteredItems,
                        onToggleBought: { item in
                            Task {
                                await viewModel.toggleItemBought(item)
                            }
                        },
                        onDelete: { item in
                            Task {
                                await viewModel.deleteItem(item)
                            }
                        },
                        onEdit: { item, name, quantity, note in
                            Task {
                                await viewModel.updateItem(item, name: name, quantity: quantity, note: note)
                            }
                        }
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Shopping List")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    SyncStatusButton(
                        isSyncing: viewModel.isSyncing,
                        syncStatus: viewModel.syncStatus,
                        hasUnsyncedChanges: viewModel.statistics.hasUnsyncedChanges,
                        onSync: {
                            Task {
                                await viewModel.sync()
                            }
                        }
                    )
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #else
                ToolbarItemGroup(placement: .primaryAction) {
                    SyncStatusButton(
                        isSyncing: viewModel.isSyncing,
                        syncStatus: viewModel.syncStatus,
                        hasUnsyncedChanges: viewModel.statistics.hasUnsyncedChanges,
                        onSync: {
                            Task {
                                await viewModel.sync()
                            }
                        }
                    )
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .refreshable {
                await viewModel.loadItems()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await viewModel.loadItems()
        }
    }
}

// MARK: - Search and Filter Bar (using extracted component)

// MARK: - Shopping Items List

struct ShoppingItemsList: View {
    let items: [ShoppingItem]
    let onToggleBought: (ShoppingItem) -> Void
    let onDelete: (ShoppingItem) -> Void
    let onEdit: (ShoppingItem, String, Int, String?) -> Void
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                ShoppingItemRow(
                    item: item,
                    onToggleBought: { onToggleBought(item) },
                    onEdit: { name, quantity, note in
                        onEdit(item, name, quantity, note)
                    }
                )
            }
            .onDelete { indexSet in
                for index in indexSet {
                    onDelete(items[index])
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Shopping Item Row (using extracted component)

// MARK: - Add Item Sheet (using extracted component)

// MARK: - Edit Item Sheet (using extracted component)

// MARK: - Empty State View (using extracted component)

// MARK: - Loading View (using extracted component)

// MARK: - Sync Status Button

struct SyncStatusButton: View {
    let isSyncing: Bool
    let syncStatus: String
    let hasUnsyncedChanges: Bool
    let onSync: () -> Void
    
    var body: some View {
        Button(action: onSync) {
            HStack(spacing: 4) {
                if isSyncing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: hasUnsyncedChanges ? "arrow.up.circle.fill" : "arrow.triangle.2.circlepath")
                        .foregroundColor(hasUnsyncedChanges ? .orange : .secondary)
                }
            }
        }
        .disabled(isSyncing)
        .help(syncStatus)
    }
}

// MARK: - Preview Provider

#Preview {
    ShoppingListView(viewModel: .preview)
}
