import Foundation
import ShoppingListModule

print("Testing ShoppingListModule integration...")

// Test that we can import the module
print("✅ Successfully imported ShoppingListModule")

// Test that we can access the main view
let view = ShoppingListView()
print("✅ Successfully created ShoppingListView")

// Test that we can access the main module
let module = ShoppingListModule()
print("✅ Successfully created ShoppingListModule")

print("🎉 All tests passed! ShoppingListModule is ready for SPM publishing.") 