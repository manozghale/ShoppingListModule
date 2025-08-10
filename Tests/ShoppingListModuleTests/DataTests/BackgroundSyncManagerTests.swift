import XCTest
@testable import ShoppingListModule

final class BackgroundSyncManagerTests: XCTestCase {

    func testScheduleBackgroundSyncDoesNotCrash() async throws {
        // Should be safe in all environments (no crash)
        await BackgroundSyncManager.shared.scheduleBackgroundSync()
        XCTAssertTrue(true)
    }

    func testRegisterBackgroundTasksSafeToCall() async throws {
        await BackgroundSyncManager.shared.registerBackgroundTasks()
        XCTAssertTrue(true)
    }

    #if canImport(BackgroundTasks)
    func testCanCallScheduleWhenBackgroundTasksAvailable() async throws {
        // This ensures the path covered by BGTaskScheduler is at least invocable
        await BackgroundSyncManager.shared.registerBackgroundTasks()
        await BackgroundSyncManager.shared.scheduleBackgroundSync()
        XCTAssertTrue(true)
    }
    #endif
}


