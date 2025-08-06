# ShoppingListModule Integration Guide

## Overview

This guide provides comprehensive instructions for integrating the ShoppingListModule into your iOS super-app. The module is designed to be easily integrated with minimal setup and maximum flexibility.

## Quick Start

### 1. Add Package Dependency

**In Xcode:**

1. Go to **File** → **Add Package Dependencies**
2. Enter: `https://github.com/manozghale/ShoppingListModule.git`
3. Select version: `1.0.0`
4. Add to your target

**In Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/manozghale/ShoppingListModule.git", from: "1.0.0")
]
```

### 2. Basic Integration

```swift
import SwiftUI
import ShoppingListModule

struct ContentView: View {
    var body: some View {
        NavigationView {
            ShoppingListView()
                .navigationTitle("Shopping List")
        }
    }
}
```

## Integration Patterns

### Pattern 1: Standalone Module Integration

```swift
import SwiftUI
import ShoppingListModule

struct ShoppingListTabView: View {
    var body: some View {
        NavigationView {
            ShoppingListView()
                .navigationTitle("Shopping List")
                .navigationBarTitleDisplayMode(.large)
        }
        .tabItem {
            Image(systemName: "cart")
            Text("Shopping")
        }
    }
}
```

### Pattern 2: Embedded in Existing View

```swift
import SwiftUI
import ShoppingListModule

struct HomeView: View {
    @State private var showShoppingList = false

    var body: some View {
        VStack {
            // Your existing home content
            Text("Welcome to Super App")

            Button("Open Shopping List") {
                showShoppingList = true
            }
        }
        .sheet(isPresented: $showShoppingList) {
            NavigationView {
                ShoppingListView()
                    .navigationTitle("Shopping List")
                    .navigationBarItems(trailing: Button("Done") {
                        showShoppingList = false
                    })
            }
        }
    }
}
```

### Pattern 3: UIKit Integration

```swift
import UIKit
import SwiftUI
import ShoppingListModule

class ShoppingListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                let shoppingListVC = try await ShoppingListModule.createViewController()
                addChild(shoppingListVC)
                view.addSubview(shoppingListVC.view)
                shoppingListVC.view.frame = view.bounds
                shoppingListVC.didMove(toParent: self)
            } catch {
                print("Failed to create shopping list view controller: \(error)")
            }
        }
    }
}
```

## Advanced Integration

### Custom Configuration

```swift
import SwiftUI
import ShoppingListModule

struct CustomShoppingListView: View {
    var body: some View {
        ShoppingListView()
            .onAppear {
                // Configure the module with custom settings
                Task {
                    do {
                        let configuration = ShoppingListConfiguration(
                            apiBaseURL: URL(string: "https://your-api.com"),
                            isTestMode: false,
                            syncInterval: 300 // 5 minutes
                        )

                        try await ShoppingListModuleFactory.setupModule(configuration: configuration)
                    } catch {
                        print("Configuration error: \(error)")
                    }
                }
            }
    }
}
```

### Custom Styling

```swift
import SwiftUI
import ShoppingListModule

struct StyledShoppingListView: View {
    var body: some View {
        ShoppingListView()
            .accentColor(.blue) // Custom accent color
            .preferredColorScheme(.dark) // Force dark mode
            .environment(\.colorScheme, .dark)
    }
}
```

## Programmatic Access

### Accessing ViewModel

```swift
import SwiftUI
import ShoppingListModule

struct ShoppingListWithActions: View {
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        VStack {
            if let viewModel = viewModel {
                ShoppingListView()
                    .environmentObject(viewModel)
            } else {
                ProgressView("Loading...")
            }

            // Custom actions
            HStack {
                Button("Add Sample Items") {
                    Task {
                        await viewModel?.addItem(name: "Milk", quantity: 1)
                        await viewModel?.addItem(name: "Bread", quantity: 2)
                    }
                }

                Button("Clear All") {
                    Task {
                        // Clear all items
                        for item in viewModel?.items ?? [] {
                            await viewModel?.deleteItem(item)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    viewModel = try await ShoppingListModule.createViewModel()
                } catch {
                    print("Failed to create view model: \(error)")
                }
            }
        }
    }
}
```

### Custom Data Integration

```swift
import SwiftUI
import ShoppingListModule

struct ShoppingListWithCustomData: View {
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        ShoppingListView()
            .onAppear {
                setupCustomData()
            }
    }

    private func setupCustomData() {
        Task {
            do {
                let viewModel = try await ShoppingListModule.createViewModel()

                // Add custom items
                await viewModel.addItem(name: "Custom Item 1", quantity: 1, note: "From super app")
                await viewModel.addItem(name: "Custom Item 2", quantity: 3, note: "Important")

                // Set custom filter
                await viewModel.setFilter(.active)

                // Set custom sort
                await viewModel.setSort(.nameAscending)

            } catch {
                print("Failed to setup custom data: \(error)")
            }
        }
    }
}
```

## Navigation Integration

### Tab Bar Integration

```swift
import SwiftUI
import ShoppingListModule

struct MainTabView: View {
    var body: some View {
        TabView {
            // Home tab
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            // Shopping List tab
            NavigationView {
                ShoppingListView()
                    .navigationTitle("Shopping List")
            }
            .tabItem {
                Image(systemName: "cart")
                Text("Shopping")
            }

            // Settings tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
```

### Navigation Stack Integration

```swift
import SwiftUI
import ShoppingListModule

struct AppNavigationView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Shopping List") {
                    ShoppingListView()
                        .navigationTitle("Shopping List")
                        .navigationBarTitleDisplayMode(.large)
                }

                NavigationLink("Other Features") {
                    Text("Other features")
                }
            }
            .navigationTitle("Super App")
        }
    }
}
```

## Error Handling

### Graceful Error Handling

```swift
import SwiftUI
import ShoppingListModule

struct SafeShoppingListView: View {
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Group {
            if showError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text("Failed to load Shopping List")
                        .font(.headline)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Retry") {
                        loadShoppingList()
                    }
                }
            } else {
                ShoppingListView()
            }
        }
        .onAppear {
            loadShoppingList()
        }
    }

    private func loadShoppingList() {
        Task {
            do {
                try await ShoppingListModuleFactory.setupModule()
                showError = false
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
```

## Customization Examples

### Custom Theme Integration

```swift
import SwiftUI
import ShoppingListModule

struct ThemedShoppingListView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ShoppingListView()
            .accentColor(.purple)
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.black, Color.purple.opacity(0.3)]
                        : [Color.white, Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
```

### Custom Actions

```swift
import SwiftUI
import ShoppingListModule

struct ShoppingListWithCustomActions: View {
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        VStack {
            ShoppingListView()

            // Custom action buttons
            HStack {
                Button("Export List") {
                    exportShoppingList()
                }
                .buttonStyle(.borderedProminent)

                Button("Share List") {
                    shareShoppingList()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            Task {
                viewModel = try await ShoppingListModule.createViewModel()
            }
        }
    }

    private func exportShoppingList() {
        // Custom export logic
        guard let items = viewModel?.items else { return }

        let exportText = items.map { item in
            "- \(item.name) (Qty: \(item.quantity))"
        }.joined(separator: "\n")

        // Share or save the export
        print("Exporting: \(exportText)")
    }

    private func shareShoppingList() {
        // Custom share logic
        guard let items = viewModel?.items else { return }

        let shareText = "My Shopping List:\n" + items.map { item in
            "• \(item.name) x\(item.quantity)"
        }.joined(separator: "\n")

        // Implement sharing
        print("Sharing: \(shareText)")
    }
}
```

## Testing Integration

### Unit Test Example

```swift
import XCTest
import ShoppingListModule
@testable import YourApp

class ShoppingListIntegrationTests: XCTestCase {

    func testShoppingListIntegration() async throws {
        // Test module creation
        let viewModel = try await ShoppingListModule.createViewModel()
        XCTAssertNotNil(viewModel)

        // Test adding items
        await viewModel.addItem(name: "Test Item", quantity: 1)
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.name, "Test Item")

        // Test filtering
        await viewModel.setFilter(.active)
        XCTAssertEqual(viewModel.filteredItems.count, 1)
    }
}
```

## Best Practices

### 1. Configuration Management

```swift
// Store configuration in your app's settings
class AppSettings {
    static let shared = AppSettings()

    var shoppingListAPIURL: URL? {
        get { UserDefaults.standard.url(forKey: "shoppingListAPIURL") }
        set { UserDefaults.standard.set(newValue, forKey: "shoppingListAPIURL") }
    }

    var shoppingListSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "shoppingListSyncEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "shoppingListSyncEnabled") }
    }
}
```

### 2. Error Handling

```swift
// Centralized error handling
enum ShoppingListError: Error {
    case initializationFailed
    case configurationError
    case networkError
}

func handleShoppingListError(_ error: Error) {
    // Log error
    print("Shopping List Error: \(error)")

    // Show user-friendly message
    // Implement your app's error handling strategy
}
```

### 3. Performance Optimization

```swift
// Lazy loading for better performance
struct LazyShoppingListView: View {
    @State private var isLoaded = false

    var body: some View {
        Group {
            if isLoaded {
                ShoppingListView()
            } else {
                ProgressView("Loading Shopping List...")
                    .onAppear {
                        // Load only when needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isLoaded = true
                        }
                    }
            }
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Module not found**: Ensure the package is properly added to your target
2. **Build errors**: Check that you're using iOS 17+ and Swift 6.1+
3. **Runtime errors**: Verify that the module is properly initialized before use
4. **UI issues**: Check that the view is properly embedded in a navigation context

### Debug Tips

```swift
// Enable debug logging
#if DEBUG
print("ShoppingListModule: Initializing...")
#endif

// Check module status
Task {
    do {
        let viewModel = try await ShoppingListModule.createViewModel()
        print("ShoppingListModule: Successfully created view model")
    } catch {
        print("ShoppingListModule: Error - \(error)")
    }
}
```

---

This integration guide provides comprehensive examples for integrating the ShoppingListModule into your super-app. The module is designed to be flexible and can be integrated in various ways depending on your app's architecture and requirements.
