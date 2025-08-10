# ShoppingListModule

A production-ready, modular shopping list feature built for iOS apps using **SwiftUI**, **SwiftData**, and **Clean Architecture** principles. This module implements a complete offline-first shopping list solution with background synchronization, conflict resolution, and comprehensive testing.

## 📦 Installation

### Overview

- **SwiftUI-first** module with optional **UIKit** wrapper.
- Zero-config view for quick start and a factory for custom setups.
- Two primary environments:
  - **.development**: in-memory mock repo + mock network (fast iteration; no persistence).
  - **.production**: SwiftData persistence + HTTP network (realistic; background sync enabled).

### SwiftUI: Quick start (zero-config)

Uses `.development` under the hood for a fast mock setup.
x

```swift
import SwiftUI
import ShoppingListModule

struct ContentView: View {
    var body: some View {
        ShoppingListModule.createSimpleView()
    }
}
```

- Pros: fastest way to see the UI working.
- Note: items are not persisted across app restarts in this mode (mock/in-memory).

### SwiftUI: Custom ViewModel (recommended for real offline persistence)

Create a ViewModel with a custom `ShoppingListConfiguration` and inject it.

```swift
import SwiftUI
import ShoppingListModule

struct CustomShoppingListScreen: View {
    @State private var viewModel: ShoppingListViewModel?
    @State private var error: (any Error)?

    var body: some View {
        Group {
            if let vm = viewModel {
                ShoppingListView(viewModel: vm)
            } else if let error {
                Text("Error: \(error.localizedDescription)")
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                // Offline dev with real persistence (SwiftData), no network
                let config = ShoppingListConfiguration(
                    apiBaseURL: nil,          // no server → mock network
                    enableBackgroundSync: false,
                    isTestMode: false         // crucial: use SwiftData repo (persistent)
                )
                viewModel = try await ShoppingListModule.createViewModel(configuration: config)
            } catch {
                self.error = error
            }
        }
    }
}
```

### Environment modes and when to use them

- **.development**
  - `apiBaseURL = nil`, `enableBackgroundSync = false`, `isTestMode = true`
  - In-memory repo + mock network; fast iteration; no persistence.
  - Ideal for UI prototyping and demoing components.
- **.production**
  - `apiBaseURL = https://api.example.com/shopping`, `enableBackgroundSync = true`, `isTestMode = false`
  - SwiftData persistence + HTTP network; background sync enabled.
  - Replace the placeholder URL with your real endpoint.
- **Offline dev with persistence (recommended for testing offline)**
  - `apiBaseURL = nil`, `enableBackgroundSync = false`, `isTestMode = false`
  - SwiftData persistence + mock network (no server); items persist across restarts.

### Enabling background sync (iOS)

1. Add to host app’s `Info.plist`:
   - `BGTaskSchedulerPermittedIdentifiers`: `com.shoppinglist.sync`
2. Capabilities:
   - Enable “Background Modes” → “Background fetch” and/or “Background processing”.
3. Register at app startup:

   ```swift
   import ShoppingListModule

   @MainActor
   func setupModule(_ application: UIApplication) async throws {
       try await ShoppingListModuleFactory.setupModule(in: application, configuration: .production)
   }
   ```

4. Optionally schedule refreshes (e.g., after first foreground sync or app launch):
   ```swift
   BackgroundSyncManager.shared.scheduleBackgroundSync()
   ```

### How `ParentShoppingApp` can showcase options

- Keep a simple menu with links to:
  - **Simple (mock/in-memory)**: `SimpleShoppingListView()` for instant demo.
  - **Custom ViewModel**: use the “offline dev with persistence” config above.
  - **Tabbed or Embedded**: host `ShoppingListView` inside your own containers.

### Testing offline behavior

- Use the “offline dev with persistence” config (`isTestMode = false`, `apiBaseURL = nil`).
- Airplane mode or no network has no effect—network is mocked; data persists via SwiftData.
- Tap the sync toolbar button in `ShoppingListView` to exercise sync UI (with mock, it’s a no-op).

### Notes

- The sync toolbar button in `ShoppingListView` shows status and triggers `viewModel.sync()`.
- Replace the placeholder production API URL in `ShoppingListConfiguration.production` with your real endpoint.
