# ShoppingListModule – Design Summary (<= 600 words)

## Goals

- Modular shopping list feature that plugs into host apps via Swift Package.
- Offline-first UX with local persistence and background synchronization.
- Clean Architecture with MVVM and Repository; minimal dependencies.

## Architecture

- **Layers**
  - **Presentation**: `ShoppingListView` (SwiftUI), components (search/filter bar, item row, sheets), `ShoppingListViewModel` (state, validation, orchestration).
  - **Domain/Business**: `SyncService` (push/pull with retry), `ShoppingItem` domain model with business logic, error mapping.
  - **Data**: `ShoppingListRepository` protocol with `SwiftDataShoppingRepository` and `MockShoppingListRepository`; `NetworkService` protocol with `HTTPShoppingNetworkService` and `MockNetworkService`.
- **DI & Composition**
  - `ShoppingListModuleFactory` builds the dependency graph based on `ShoppingListConfiguration`.
  - `ShoppingListDependencies` implements Service Locator pattern for runtime registration/resolution.
  - Clean separation between production and testing configurations.

## Offline-first

- **Persistence**: `SwiftDataShoppingRepository` stores `ShoppingItem` model with timestamps and sync flags using SwiftData's `@Model` annotation.
- **Conflict resolution**: last-write-wins using `modifiedAt` during `mergeRemoteItems` in repository.
- **Sync**: `ShoppingSyncService` publishes `SyncState` via Combine; operations are async/await with exponential backoff and jitter.
- **Background**: `BackgroundSyncManager` registers/schedules BGTask (identifier `com.shoppinglist.sync`) and triggers `synchronize()`; re-schedules on completion.

## Models

- `ShoppingItem` includes `id`, `name`, `quantity`, `note`, `isBought`, `createdAt`, `modifiedAt`, `syncStatus`, `lastSyncedAt`, `isDeleted`.
- `SyncStatus` enum with `.needsSync`, `.syncing`, `.synced`, `.failed` states and computed properties.
- Filtering (`ShoppingItemFilter`), sorting (`SortOption`), and search are applied in the ViewModel with reactive updates.

## Public API

- `ShoppingListModule` provides:
  - `SimpleShoppingListView` (zero-config SwiftUI view with automatic ViewModel creation)
  - Builders: `createView(...)`, `createViewModel(...)`, `createViewController(...)` for custom or UIKit integration.
- `ShoppingListConfiguration` toggles API base URL, background sync, retry limits, and `isTestMode` (mock vs SwiftData).

## Testing

- **Unit tests** for repository, networking, sync, models, and ViewModel.
- **Integration tests** validate end-to-end behavior with mocks.
- **UI integration tests** assert view wiring and state transitions.
- **Test utilities** provide mock data and helper functions for consistent testing.

## Error Handling

- Domain-specific `ShoppingListError` and `NetworkError` map to user-facing messages via ViewModel (`errorMessage`, `showError`).
- Sync errors emitted on `syncStatusPublisher` and surfaced via toolbar status.
- Comprehensive error mapping from network layer to presentation layer.

## Performance & Simplicity

- Avoids heavy frameworks; minimal allocations in hot paths.
- Batches local sync updates (mark as synced/failed) and defers UI updates to main actor.
- Uses `FetchDescriptor` with predicates and sort descriptors for SwiftData queries.
- Service Locator pattern provides lightweight dependency injection without external frameworks.

## Rejected Alternatives

1. **Heavy DI frameworks** (e.g., Resolver/Swinject)

   - Rejected to keep the module lightweight, dependency-free, and easy to embed. The simple service-locator pattern suffices and is test-friendly.

2. **Complex conflict resolution** (CRDTs or per-field merge)
   - Overkill for a shopping list. Last-write-wins (timestamp-based) is predictable, easy to reason about, and meets the challenge requirements.

## Host App Integration Notes

- **Background tasks**: add `BGTaskSchedulerPermittedIdentifiers` to host Info.plist with `com.shoppinglist.sync` and enable the Background Modes capability (Background fetch/processing). Call `ShoppingListModuleFactory.setupModule(..., configuration:)` with `enableBackgroundSync = true`.
- **Persistence**: use `isTestMode = false` (e.g., `.production` or custom with `apiBaseURL = nil`) to enable SwiftData storage for true offline persistence. `.development` uses mock repo (in-memory) for rapid iteration.

## Future Work

- Provide migration strategies for SwiftData schema changes.
- Pluggable conflict policies (configurable resolver).
- More granular sync progress reporting (items processed counts).
- Enhanced background task scheduling and battery optimization.
