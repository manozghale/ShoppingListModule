//
//  DESIGN_DOC.md
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

# Shopping List Module - Design Document

## Architecture Overview

This shopping list module implements a **Clean Architecture** pattern adapted for iOS development, combining **MVVM** for presentation layer organization with **Repository pattern** for data access abstraction. The design prioritizes offline-first functionality, testability, and modularity.

## Key Architectural Decisions

### 1. Offline-First with SwiftData

**Decision**: Use SwiftData as the primary persistence layer with local-first data flow.

**Rationale**: 
- SwiftData provides type-safe, Swift-native persistence with minimal boilerplate
- Local-first ensures the app works seamlessly without network connectivity
- SwiftData's model-driven approach integrates well with SwiftUI's reactive patterns

**Implementation**: The `ShoppingItem` model serves as both domain entity and SwiftData model, including sync metadata (`syncStatus`, `modifiedAt`, `lastSyncedAt`) for conflict resolution.

### 2. Repository Pattern for Data Abstraction

**Decision**: Abstract all data operations behind a `ShoppingListRepository` protocol.

**Rationale**:
- Enables easy testing with mock implementations
- Separates business logic from persistence details
- Allows future migration to different storage solutions
- Provides clean interface for sync operations

**Implementation**: `SwiftDataShoppingRepository` handles production persistence while `MockShoppingListRepository` enables comprehensive testing without database dependencies.

### 3. MVVM with Reactive Bindings

**Decision**: Use MVVM pattern with `@Published` properties for SwiftUI integration.

**Rationale**:
- Natural fit for SwiftUI's declarative, reactive nature
- Clear separation between UI logic and business logic
- `ObservableObject` provides automatic UI updates
- Enables comprehensive ViewModel testing

**Implementation**: `ShoppingListViewModel` manages all business logic, data transformations, and error handling while exposing clean, reactive properties for UI binding.

### 4. Dependency Injection via Service Locator

**Decision**: Implement lightweight dependency injection without external frameworks.

**Rationale**:
- Keeps module dependencies minimal
- Provides sufficient flexibility for testing and configuration
- Simple to understand and maintain
- Avoids framework lock-in

**Implementation**: `ShoppingListDependencies` provides thread-safe service location with factory methods for different configurations (production, development, testing).

### 5. Last-Write-Wins Conflict Resolution

**Decision**: Use timestamp-based conflict resolution for sync operations.

**Rationale**:
- Simple to implement and understand
- Sufficient for shopping list use case where conflicts are rare
- Avoids complex merge logic
- Preserves user intent (most recent change wins)

**Implementation**: Each item tracks `createdAt` and `modifiedAt` timestamps. The sync service compares timestamps during merge operations to determine which version to keep.

### 6. Background Sync with Retry Logic

**Decision**: Implement exponential backoff retry strategy for network operations.

**Rationale**:
- Mobile networks are inherently unreliable
- Exponential backoff prevents server overload
- Graceful degradation maintains user experience
- Jitter prevents thundering herd problems

**Implementation**: `ShoppingSyncService` provides configurable retry logic with exponential backoff and jitter for network resilience.

## Data Flow Architecture

```
User Action → ViewModel → Repository → SwiftData
     ↓            ↓           ↓           ↓
UI Update ← Published ← Domain Model ← Persistence
                Properties

Background: Sync Service ↔ Network Service ↔ Remote API
                   ↓              ↓
           Repository ← Conflict Resolution
```

## Module Boundaries and Interfaces

### Public Interface
- `ShoppingListView` - Primary SwiftUI integration point
- `ShoppingListViewModel` - For custom UI implementations  
- `ShoppingListModule` - Complete module interface
- `ShoppingListModuleFactory` - Configuration and creation

### Internal Components
- Domain models (`ShoppingItem`, enums, extensions)
- Data access (`ShoppingListRepository`, implementations)
- Networking (`NetworkService`, `SyncService`)
- Dependency management (`ShoppingListDependencies`)

## Testing Strategy

### Unit Tests
- Model behavior and validation
- ViewModel business logic
- Repository implementations
- Sync service operations
- Array extensions and utilities

### Integration Tests
- Complete workflows (add → sync → modify → sync)
- Error handling across layers
- Concurrent operations
- Module factory and dependency injection

### UI Tests
- SwiftUI view integration
- Filter and search functionality
- Error state presentation

## Error Handling Strategy

**Layered Approach**:
1. **Domain Level**: Custom errors (`ShoppingListError`) for business rule violations
2. **Network Level**: Structured errors (`NetworkError`) with user-friendly messages
3. **Presentation Level**: ViewModel translates errors to UI-appropriate messages
4. **User Experience**: Non-blocking error presentation with auto-dismissal

## Performance Considerations

### Memory Management
- Weak references in Combine subscriptions
- Proper disposal of cancellables
- Efficient SwiftData query predicates

### Concurrent Operations
- `@MainActor` for UI-bound operations
- Background queues for sync operations
- Thread-safe repository implementations

### Large Dataset Handling
- Efficient filtering and sorting using native Swift operations
- Lazy evaluation where appropriate
- Pagination-ready architecture for future scaling

## Rejected Alternatives

### Alternative 1: Core Data Instead of SwiftData

**Reasoning for Rejection**:
- SwiftData provides cleaner, more Swift-native API
- Eliminates NSManagedObjectContext complexity
- Better integration with SwiftUI
- Reduces boilerplate code significantly

**Trade-offs**: SwiftData requires iOS 17+, limiting deployment targets. However, the improved developer experience and reduced complexity outweigh this limitation for modern apps.

### Alternative 2: Coordinator Pattern for Navigation

**Reasoning for Rejection**:
- Shopping list has simple navigation requirements
- SwiftUI's native navigation is sufficient
- Coordinator pattern would add unnecessary complexity
- Sheet-based modals handle the limited navigation needs

**Trade-offs**: For apps with complex navigation flows, Coordinator pattern provides better navigation management. However, the shopping list feature's simple navigation doesn't justify the additional architectural overhead.

## Future Considerations

### Scalability
- The repository pattern enables easy migration to more sophisticated storage
- Sync service can be extended with operational transforms for complex conflict resolution
- Module interface supports integration into larger app architectures

### Extensibility
- Clear separation of concerns enables feature additions
- Dependency injection supports adding new services (analytics, crash reporting)
- Protocol-based design allows alternative implementations

### Platform Support
- Architecture supports macOS, iPadOS expansion
- Repository abstraction enables watchOS-optimized implementations
- Network service can be adapted for different backend systems

## Conclusion

This architecture balances pragmatism with best practices, providing a robust, testable, and maintainable shopping list module. The offline-first approach ensures excellent user experience, while the clean architecture enables easy testing and future evolution. The design successfully meets all requirements while maintaining simplicity and clarity.
