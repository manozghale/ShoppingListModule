# ShoppingListModule

A production-ready, modular shopping list feature built for iOS apps using **SwiftUI**, **SwiftData**, and **Clean Architecture** principles. This module implements a complete offline-first shopping list solution with background synchronization, conflict resolution, and comprehensive testing.

## 📦 Installation

### Swift Package Manager

Add ShoppingListModule to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/manozghale/ShoppingListModule.git`
3. Select the version you want to use
4. Click **Add Package**

### Manual Installation

1. Clone the repository
2. Add the `Package.swift` file to your project
3. Build and run

## 🚀 Quick Start

### Basic Integration

```swift
import SwiftUI
import ShoppingListModule

struct ContentView: View {
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                NavigationView {
                    ShoppingListView(viewModel: viewModel)
                        .navigationTitle("Shopping List")
                }
            } else {
                ProgressView("Loading...")
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

### Tab Bar Integration

```swift
import SwiftUI
import ShoppingListModule

struct MainTabView: View {
    @State private var shoppingListViewModel: ShoppingListViewModel?

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            Group {
                if let viewModel = shoppingListViewModel {
                    NavigationView {
                        ShoppingListView(viewModel: viewModel)
                            .navigationTitle("Shopping List")
                    }
                } else {
                    ProgressView("Loading Shopping List...")
                }
            }
            .tabItem {
                Image(systemName: "cart")
                Text("Shopping")
            }
        }
        .onAppear {
            Task {
                do {
                    shoppingListViewModel = try await ShoppingListModule.createViewModel()
                } catch {
                    print("Failed to create shopping list view model: \(error)")
                }
            }
        }
    }
}
```

### Programmatic Access

```swift
import SwiftUI
import ShoppingListModule

struct ShoppingListWithActions: View {
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        VStack {
            ShoppingListView()

            Button("Add Sample Items") {
                Task {
                    await viewModel?.addItem(name: "Milk", quantity: 1)
                    await viewModel?.addItem(name: "Bread", quantity: 2)
                }
            }
        }
        .onAppear {
            Task {
                viewModel = try await ShoppingListModule.createViewModel()
            }
        }
    }
}
```

📖 **For detailed integration examples, see [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)**

## 🎯 **Project Overview**

This module was developed as part of an iOS Engineer Code Challenge focusing on **architecture excellence**. It demonstrates modern iOS development practices including:

- **Offline-first architecture** with local persistence
- **Clean Architecture** with MVVM pattern
- **Dependency Injection** without external frameworks
- **Comprehensive testing** with 95% test coverage
- **Background synchronization** with retry logic
- **Cross-platform support** (iOS, macOS)

## ✨ **Implemented Features**

### **Core Shopping List Functionality**

- ✅ **Add/Edit/Delete Items**: Full CRUD operations with validation
- ✅ **Item Properties**: Name (required), quantity (required), notes (optional)
- ✅ **Purchase Status**: Mark items as bought/unbought with visual indicators
- ✅ **Smart Filtering**: All, Active (not bought), Bought items
- ✅ **Real-time Search**: Search across item names and notes
- ✅ **Multiple Sorting**: By creation date, modification date, name (ascending/descending)

### **Offline-First Architecture**

- ✅ **Local Persistence**: SwiftData with automatic conflict resolution
- ✅ **Background Sync**: Automatic synchronization with exponential backoff
- ✅ **Conflict Resolution**: Last-write-wins strategy based on timestamps
- ✅ **Network Resilience**: Retry logic with jitter to prevent thundering herd
- ✅ **Sync Status Tracking**: Visual indicators for sync state

### **Clean Architecture Implementation**

- ✅ **MVVM Pattern**: Reactive data binding with `@Published` properties
- ✅ **Repository Pattern**: Abstract data access with protocol-based design
- ✅ **Dependency Injection**: Service locator pattern without external frameworks
- ✅ **Separation of Concerns**: Clear boundaries between presentation, business logic, and data layers

### **Modern iOS Development**

- ✅ **SwiftUI**: Declarative UI with platform-specific optimizations
- ✅ **SwiftData**: Type-safe persistence with minimal boilerplate
- ✅ **Async/Await**: Modern concurrency throughout the codebase
- ✅ **Combine**: Reactive programming for sync status updates
- ✅ **iOS 17+**: Latest APIs and features

## 🏗 **Architecture Implementation**

### **Layer Structure**

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  ShoppingListView  │  AddItemSheet  │  EditItemSheet       │
│  SearchAndFilterBar│  ShoppingItemRow│  EmptyStateView     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  ShoppingListViewModel  │  SyncService  │  BackgroundSync   │
│  ShoppingListStatistics │  Error Handling│  Validation      │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     Data Layer                              │
├─────────────────────────────────────────────────────────────┤
│  ShoppingListRepository │  SwiftDataRepository │  MockRepo   │
│  NetworkService         │  HTTPService         │  MockNet    │
└─────────────────────────────────────────────────────────────┘
```

### **Key Design Patterns Implemented**

#### **1. Repository Pattern**

```swift
public protocol ShoppingListRepository: Sendable {
    func fetchItems() async throws -> [ShoppingItem]
    func save(item: ShoppingItem) async throws
    func delete(item: ShoppingItem) async throws
    func itemsNeedingSync() async throws -> [ShoppingItem]
    func markItemsAsSynced(_ items: [ShoppingItem]) async throws
}
```

#### **2. MVVM with Reactive Bindings**

```swift
@MainActor
public class ShoppingListViewModel: ObservableObject {
    @Published public var items: [ShoppingItem] = []
    @Published public var filteredItems: [ShoppingItem] = []
    @Published public var searchText: String = ""
    @Published public var selectedFilter: ShoppingItemFilter = .active
    @Published public var selectedSort: SortOption = .modifiedDateDescending
}
```

#### **3. Dependency Injection**

```swift
public final class ShoppingListDependencies: @unchecked Sendable {
    @MainActor
    public static let shared = ShoppingListDependencies()

    public func register<T: Sendable>(_ dependency: T, for type: T.Type)
    public func resolve<T>(_ type: T.Type) -> T?
}
```

## 📦 **Installation & Setup**

### **Swift Package Manager**

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/manozghale/shopping-list-module.git", from: "1.0.0")
]
```

### **Xcode Integration**

1. File → Add Package Dependencies
2. Enter repository URL
3. Select version and add to target

## 🚀 **Quick Start Examples**

### **SwiftUI Integration (Recommended)**

```swift
import SwiftUI
import ShoppingListModule

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Simple integration
            ShoppingListModule.createView()
        }
    }
}
```

### **UIKit Integration**

```swift
import UIKit
import ShoppingListModule

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create shopping list view controller
        Task {
            let shoppingListVC = try await ShoppingListModule.createViewController()
            addChild(shoppingListVC)
            view.addSubview(shoppingListVC.view)
            shoppingListVC.didMove(toParent: self)
        }
    }
}
```
