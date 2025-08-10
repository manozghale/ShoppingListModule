import XCTest
@testable import ShoppingListModule

/// Integration tests validating SwiftData-backed persistence
@MainActor
final class SwiftDataRepositoryIntegrationTests: XCTestCase {

    func testPersistenceAcrossRepositoryInstances() async throws {
        if #available(iOS 17.0, macOS 14.0, *) {
            // Arrange
            let uniqueName = "PersistenceTest-\(UUID().uuidString)"

            // Act: create first repository and save an item
            let repo1 = try SwiftDataShoppingRepository()
            let item = ShoppingItem(name: uniqueName, quantity: 1)
            try await repo1.save(item: item)

            // Create a fresh repository instance simulating a new app session
            let repo2 = try SwiftDataShoppingRepository()
            let fetched = try await repo2.fetchItems()

            // Assert: item with unique name exists (evidence of on-disk persistence)
            XCTAssertTrue(fetched.contains(where: { $0.name == uniqueName }))
        } else {
            throw XCTSkip("SwiftData requires iOS 17/macOS 14 or newer")
        }
    }
}


