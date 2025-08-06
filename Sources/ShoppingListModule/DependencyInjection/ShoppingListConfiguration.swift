//
//  ShoppingListConfiguration.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation

/// Configuration options for the shopping list module
public struct ShoppingListConfiguration {
    public let apiBaseURL: URL?
    public let enableBackgroundSync: Bool
    public let maxRetries: Int
    public let isTestMode: Bool
    
    public init(
        apiBaseURL: URL? = nil,
        enableBackgroundSync: Bool = true,
        maxRetries: Int = 3,
        isTestMode: Bool = false
    ) {
        self.apiBaseURL = apiBaseURL
        self.enableBackgroundSync = enableBackgroundSync
        self.maxRetries = maxRetries
        self.isTestMode = isTestMode
    }
    
    /// Default configuration for production use
    public static var production: ShoppingListConfiguration {
        ShoppingListConfiguration(
            apiBaseURL: URL(string: "https://api.example.com/shopping"), // Replace with actual API
            enableBackgroundSync: true
        )
    }
    
    /// Configuration for testing and development
    public static var development: ShoppingListConfiguration {
        ShoppingListConfiguration(
            apiBaseURL: nil, // Use mock service
            enableBackgroundSync: false,
            isTestMode: true
        )
    }
}

