import Foundation
@testable import ShoppingListModule

#if swift(>=6.0)
import Testing

@Suite("Background Sync")
struct BackgroundSyncTests {
    @Test("retryWithBackoff retries on server errors")
    func testRetryBehavior() async throws {
        // Arrange: mock repo + network that fails twice then succeeds
        let repo = MockShoppingListRepository(preloadedItems: [])
        let failing = FlakyMockNetworkService(failuresBeforeSuccess: 2)
        let sync = ShoppingSyncService(repository: repo, networkService: failing)

        // Act: call synchronize (no items; focus is on fetch path)
        try await sync.pullRemoteChanges()

        // Assert: if it reaches here, retries worked
        #expect(true)
    }
}

final class FlakyMockNetworkService: NetworkService {
    private var remainingFailures: Int
    init(failuresBeforeSuccess: Int) { self.remainingFailures = failuresBeforeSuccess }

    func fetchItems() async throws -> [ShoppingItemDTO] {
        if remainingFailures > 0 {
            remainingFailures -= 1
            throw NetworkError.serverError
        }
        return []
    }
    func createItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO { item }
    func updateItem(_ item: ShoppingItemDTO) async throws -> ShoppingItemDTO { item }
    func deleteItem(id: String) async throws {}
}

#endif


