import Foundation
import ShoppingListModule
import SwiftUI

@main
struct TestSPMIntegration {
    static func main() async {
        print("Testing ShoppingListModule integration...")
        
        // Test 1: SimpleShoppingListView creation
        print("\n1. Testing SimpleShoppingListView creation...")
        let simpleView = SimpleShoppingListView()
        print("✅ Successfully created SimpleShoppingListView: \(type(of: simpleView))")
        
        // Test 2: Manual ViewModel creation
        print("\n2. Testing manual ViewModel creation...")
        do {
            let viewModel = try await ShoppingListModuleFactory.createViewModel()
            print("✅ Successfully created ViewModel manually: \(type(of: viewModel))")
        } catch {
            print("❌ Failed to create ViewModel manually: \(error)")
        }
        
        // Test 3: createView() method
        print("\n3. Testing createView() method...")
        do {
            let view = try await ShoppingListModule.createView()
            print("✅ Successfully created view with createView(): \(type(of: view))")
        } catch {
            print("❌ Failed to create view with createView(): \(error)")
        }
        
        // Test 4: Test SwiftData persistence (this is where the crash was happening)
        print("\n4. Testing SwiftData persistence...")
        do {
            let repository = try SwiftDataShoppingRepository()
            
            // Create a test item
            let testItem = ShoppingItem(
                name: "Test Item",
                quantity: 1,
                note: "Test note",
                syncStatus: .needsSync
            )
            
            // Try to save it
            try await repository.save(item: testItem)
            print("✅ Successfully saved item to SwiftData")
            
            // Try to fetch it
            let items = try await repository.fetchItems()
            print("✅ Successfully fetched \(items.count) items from SwiftData")
            
        } catch {
            print("❌ SwiftData test failed: \(error)")
        }
        
        print("\nIntegration test completed.")
    }
} 