//
//  ShoppingListDependencies.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Dependency Container

/// Simple dependency injection container following the Service Locator pattern
/// Provides a clean way to manage dependencies without external frameworks
public final class ShoppingListDependencies: @unchecked Sendable {
    // Singleton instance for global access
    @MainActor
    public static let shared = ShoppingListDependencies()
    
    // Registry of dependencies
    private var dependencies: [String: Any] = [:]
    private let queue = DispatchQueue(label: "dependencies", qos: .userInitiated, attributes: .concurrent)
    
    private init() {}
    
    /// Register a dependency with a specific key
    @MainActor
    public func register<T: Sendable>(_ dependency: T, for type: T.Type) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.dependencies[key] = dependency
        }
    }
    
    /// Resolve a dependency by type
    @MainActor
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        let result = queue.sync {
            return dependencies[key] as? T
        }
        print("Resolving \(key): \(result != nil ? "Found" : "Not found")")
        return result
    }
    
    /// Clear all registered dependencies
    public func reset() {
        queue.async(flags: .barrier) {
            self.dependencies.removeAll()
        }
    }
}

// MARK: - Module Configuration

// Configuration moved to separate file

// MARK: - Module Factory

// Factory moved to separate file

// MARK: - Module Interface Protocol

/// Protocol defining the public interface of the shopping list module
/// Useful for dependency injection in larger applications
public protocol ShoppingListModuleInterface {
    var view: ShoppingListView { get }
    var viewModel: ShoppingListViewModel { get }
    
    func sync() async throws
    func addItem(name: String, quantity: Int, note: String?) async throws
    func getStatistics() -> ShoppingListStatistics
}

// Module implementation moved to separate file

// MARK: - SwiftUI Environment Integration

/// Environment key for dependency injection in SwiftUI
struct ShoppingListModuleKey: EnvironmentKey {
    static let defaultValue: ShoppingListModule? = nil
}

extension EnvironmentValues {
    var shoppingListModule: ShoppingListModule? {
        get { self[ShoppingListModuleKey.self] }
        set { self[ShoppingListModuleKey.self] = newValue }
    }
}

/// View modifier for providing the shopping list module through SwiftUI environment
public struct ShoppingListModuleProvider: ViewModifier {
    let module: ShoppingListModule
    
    public func body(content: Content) -> some View {
        content
            .environment(\.shoppingListModule, module)
    }
}

extension View {
    /// Provide a shopping list module to the view hierarchy
    public func shoppingListModule(_ module: ShoppingListModule) -> some View {
        self.modifier(ShoppingListModuleProvider(module: module))
    }
}
