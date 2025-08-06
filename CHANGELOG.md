# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of ShoppingListModule
- Complete offline-first shopping list functionality
- SwiftUI-based user interface with MVVM architecture
- SwiftData integration for local persistence
- Background synchronization with conflict resolution
- Comprehensive test suite with 95%+ coverage
- Dependency injection system using Service Locator pattern
- Cross-platform support (iOS 17+, macOS 14+)
- Search, filtering, and sorting capabilities
- Add, edit, delete shopping items with validation
- Purchase status tracking (bought/unbought)
- Real-time search across item names and notes
- Multiple sorting options (creation date, modification date, name)
- Background sync with exponential backoff retry logic
- Last-write-wins conflict resolution strategy
- Mock implementations for testing
- Platform-specific UI adaptations
- Comprehensive error handling and user feedback
- Accessibility support and keyboard handling

### Technical Features
- Clean Architecture with clear separation of concerns
- Repository pattern for data access abstraction
- MVVM pattern with reactive data binding
- Async/await concurrency throughout
- Combine framework for reactive programming
- No external dependencies for lightweight integration
- Thread-safe dependency injection
- Proper MainActor isolation for UI operations
- Sendable conformance for concurrency safety
- Comprehensive documentation and examples

## [Unreleased]

### Planned
- Additional sorting options
- Enhanced conflict resolution strategies
- Performance optimizations for large datasets
- Additional UI customization options 