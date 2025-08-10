//
//  ShoppingListModule.swift
// Main public interface for the Shopping List Module
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Main interface for the Shopping List Module
/// This is the primary entry point for consuming applications
public struct ShoppingListModule: Sendable {
    
    /// Create a SwiftUI view with default configuration
    @MainActor
    public static func createView() async -> some View {
        do {
            return AnyView(try await ShoppingListModuleFactory.createShoppingListView())
        } catch {
            return AnyView(ErrorView(error: error))
        }
    }
    
    /// Create a SwiftUI view that automatically handles ViewModel creation
    /// This is the simplest integration method - just use SimpleShoppingListView()
    @MainActor
    public static func createSimpleView() -> some View {
        AnyView(SimpleShoppingListView())
    }
    
    /// Create a SwiftUI view with custom configuration
    @MainActor
    public static func createView(configuration: ShoppingListConfiguration) async -> some View {
        do {
            return AnyView(try await ShoppingListModuleFactory.createShoppingListView(configuration: configuration))
        } catch {
            return AnyView(ErrorView(error: error))
        }
    }
    
    /// Create a UIViewController for UIKit integration
    #if canImport(UIKit)
    @MainActor
    public static func createViewController(
        configuration: ShoppingListConfiguration = .production
    ) async throws -> UIViewController {
        return try await ShoppingListModuleFactory.createViewController(configuration: configuration)
    }
    #endif
    
    /// Create just the ViewModel for custom UI implementations
    @MainActor
    public static func createViewModel(
        configuration: ShoppingListConfiguration = .production
    ) async throws -> ShoppingListViewModel {
        return try await ShoppingListModuleFactory.createViewModel(configuration: configuration)
    }
}

/// Simple error view for configuration failures
private struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Module Error")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// Public view that automatically handles ViewModel creation
/// This is the primary integration method for most use cases
public struct SimpleShoppingListView: View {
    @State private var viewModel: ShoppingListViewModel?
    @State private var error: Error?
    
    public init() {}
    
    public var body: some View {
        Group {
            if let viewModel = viewModel {
                ShoppingListView(viewModel: viewModel)
            } else if let error = error {
                ErrorView(error: error)
            } else {
                LoadingView()
            }
        }
        .task {
            do {
                viewModel = try await ShoppingListModule.createViewModel(configuration: .development)
            } catch {
                self.error = error
            }
        }
    }
}
