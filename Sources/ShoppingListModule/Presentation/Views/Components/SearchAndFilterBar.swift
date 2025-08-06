//
//  SearchAndFilterBar.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Search and filter bar component for the shopping list
public struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedFilter: ShoppingItemFilter
    @Binding var selectedSort: SortOption
    @Binding var showingFilters: Bool
    
    public init(
        searchText: Binding<String>,
        selectedFilter: Binding<ShoppingItemFilter>,
        selectedSort: Binding<SortOption>,
        showingFilters: Binding<Bool>
    ) {
        self._searchText = searchText
        self._selectedFilter = selectedFilter
        self._selectedSort = selectedSort
        self._showingFilters = showingFilters
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search items...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ShoppingItemFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.displayName,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                selectedSort = option
                            } label: {
                                HStack {
                                    Text(option.displayName)
                                    if selectedSort == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterChip(
                            title: "Sort",
                            isSelected: false
                        ) { }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
    }
}

/// Individual filter chip component
public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        #if os(iOS)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                        #else
                        .fill(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
                        #endif
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

