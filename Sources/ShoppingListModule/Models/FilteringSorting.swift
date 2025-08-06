//
//  FilteringSorting.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Filter options for shopping items
/// Controls which items are displayed in the list
public enum ShoppingItemFilter: String, CaseIterable {
    case all = "all"
    case active = "active"
    case bought = "bought"
    
    public var displayName: String {
        switch self {
        case .all:
            return "All Items"
        case .active:
            return "Active"
        case .bought:
            return "Bought"
        }
    }
    
    public var iconName: String {
        switch self {
        case .all:
            return "list.bullet"
        case .active:
            return "cart"
        case .bought:
            return "checkmark.circle"
        }
    }
}

