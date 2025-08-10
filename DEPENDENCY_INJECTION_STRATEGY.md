# Dependency Injection Strategy

## 🎯 DI Strategy Overview

We use the **Factory Pattern** as the primary dependency injection strategy. The factory is the single integration point that constructs, configures, and wires all dependencies for the module based on a `ShoppingListConfiguration` (production, testing, preview). Internally, we currently leverage a lightweight service locator for instance management, but the public strategy is factory-based and does not require consumers to interact with any container.

Why this update? It makes the DI story explicit and easy to reason about at the module seam, while remaining testable and framework‑independent.

## 🏗 Chosen Approach: Factory Pattern (with internal instance management)

### Why Factory Pattern?

- **Clear integration seam**: A single place (`ShoppingListModuleFactory`) to create views or view models with correct dependencies.
- **Testability**: Factories make it trivial to produce configurations with mocks and stubs.
- **No framework lock‑in**: Pure Swift, zero external DI dependencies.
- **Discoverability**: Consumers only learn one API to use the module.
- **Composable**: Keeps wiring close to where lifecycle and configuration are known.

### How this maps to our code

- `ShoppingListModuleFactory` creates and configures:
  - `ShoppingListRepository` (SwiftData vs mock)
  - `NetworkService` (HTTP vs mock)
  - `SyncService` (composes repository + network)
  - `ShoppingListViewModel`
- Today, the factory registers and resolves instances via `ShoppingListDependencies` as an internal implementation detail. Consumers should treat the factory as the DI boundary. If/when we move to pure factory/manual wiring, this remains a non‑breaking change for consumers.

## 🔧 Implementation Details

### Factory responsibilities

- Interpret `ShoppingListConfiguration`
- Construct concrete implementations (prod or mock)
- Wire dependencies together in the correct order
- Produce either a `ShoppingListView` or a `ShoppingListViewModel`

### Usage

```swift
// Simplest SwiftUI entry point
let view = try await ShoppingListModuleFactory.createShoppingListView()

// Or get a view model if you are embedding into a custom UI
let viewModel = try await ShoppingListModuleFactory.createViewModel()
```

### Configuration

```swift
// Example: provide an API base URL, or enable test mode
let config = ShoppingListConfiguration(apiBaseURL: URL(string: "https://api.example.com"),
                                       isTestMode: false)
let view = try await ShoppingListModuleFactory.createShoppingListView(configuration: config)
```

### Current internal instance management

- The factory uses `ShoppingListDependencies` (a small service locator) to register and resolve instances it creates. This is internal; consumers do not need to resolve from the container.
- This indirection keeps the factory simple and centralized today while allowing an easy migration to pure manual wiring later.

## 🧪 Testing with the Factory

- For unit tests, prefer creating a `ShoppingListViewModel` with explicit mocks. The factory supports a testing configuration and can be extended with helpers to return a fully mocked view model.
- Example pattern:

```swift
let mockRepository = MockShoppingListRepository(preloadedItems: [])
        let mockNetworkService = MockNetworkService()
let sync = ShoppingSyncService(repository: mockRepository, networkService: mockNetworkService)
let viewModel = ShoppingListViewModel(repository: mockRepository, syncService: sync)
```

This keeps tests explicit and fast. For integration tests, use `ShoppingListModuleFactory.createViewModel(configuration: .testing)` once available, or construct the configuration you need.

## 🔄 Lifecycle & Flow

1. App calls `ShoppingListModuleFactory.createShoppingListView(...)`
2. Factory interprets `ShoppingListConfiguration`
3. Factory constructs Repository → Network → Sync Service
4. Factory constructs `ShoppingListViewModel`
5. Factory returns the `ShoppingListView` bound to the view model

Dependency graph:

```text
ShoppingListView
    ↓
ShoppingListViewModel
    ↓
├── ShoppingListRepository (SwiftDataShoppingRepository | MockShoppingListRepository)
└── SyncService (ShoppingSyncService)
    ├── ShoppingListRepository
    └── NetworkService (HTTPShoppingNetworkService | MockNetworkService)
```

## 🤝 Alternatives and Tradeoffs

We explicitly considered the three options requested and selected the Factory Pattern.

- Resolver (external DI container)

  - ✅ Powerful, flexible graphs; mature ecosystem
  - ❌ Adds a runtime dependency (lock‑in, learning curve)
  - ❌ Overkill for a small, self‑contained module

- Factory Pattern (chosen)

  - ✅ Clear seam, excellent testability, no external deps
  - ✅ Keeps composition near configuration and lifecycle
  - ⚠️ A bit more wiring code vs a container, but localized

- Manual Injection (module‑wide)
  - ✅ Maximum explicitness and compile‑time safety
  - ❌ Boilerplate if applied everywhere; scales poorly across call sites
  - ✅ We still use manual injection inside the factory to wire components

## 🗣 Explain it to a teammate

We use a factory to build the module. You call the factory with a configuration; it creates the repository, network, and sync service, then builds the view model and returns the view. The factory owns the wiring so consumers never need to resolve dependencies. Internally, we currently park the instances in a tiny container that the factory controls; we can later remove that indirection without changing the public API.

## 🔒 Concurrency & Safety

- The internal container is thread‑safe (barrier writes, concurrent reads) and `@MainActor` isolated where appropriate.
- Public factory methods are `@MainActor` as they produce UI‑bound types.

## 🚀 Migration Notes

- Today: Factory uses an internal service locator to register/resolve the instances it just created.
- Tomorrow: We can remove the container and keep pure factory wiring with no public API changes.
- If we ever outgrow this setup, we can adopt Resolver/Swinject behind the factory boundary without impacting consumers.

## 📌 Quick Reference

- Preferred integration: `ShoppingListModuleFactory.createShoppingListView(...)`
- Preferred test strategy: construct a `ShoppingListViewModel` with mocks, or use a testing configuration through the factory.
- No external DI frameworks required.

---

This strategy keeps integration dead simple, testing straightforward, and avoids framework lock‑in while leaving room to evolve.
