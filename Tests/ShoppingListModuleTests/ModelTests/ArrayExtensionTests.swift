//
//  ArrayExtensionTests.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import XCTest
@testable import ShoppingListModule

final class ArrayExtensionTests: XCTestCase {
    
    var testItems: [ShoppingItem]!
    
    override func setUp() {
        super.setUp()
        testItems = [
            ShoppingItem(name: "Apple", quantity: 3, note: "Red delicious", isBought: true),
            ShoppingItem(name: "Banana", quantity: 2, note: "Yellow"),
            ShoppingItem(name: "Milk", quantity: 1, note: "Organic"),
            ShoppingItem(name: "Bread", quantity: 2, isBought: true)
        ]
    }
    
    func testFilteredByAll() {
        let filtered = testItems.filtered(by: .all)
        XCTAssertEqual(filtered.count, 4)
    }
    
    func testFilteredByActive() {
        let filtered = testItems.filtered(by: .active)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { !$0.isBought })
    }
    
    func testFilteredByBought() {
        let filtered = testItems.filtered(by: .bought)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { $0.isBought })
    }
    
    func testSearchedWithQuery() {
        let searched = testItems.searched(query: "apple")
        XCTAssertEqual(searched.count, 1)
        XCTAssertEqual(searched.first?.name, "Apple")
    }
    
    func testSearchedWithNoteQuery() {
        let searched = testItems.searched(query: "organic")
        XCTAssertEqual(searched.count, 1)
        XCTAssertEqual(searched.first?.name, "Milk")
    }
    
    func testSearchedWithEmptyQuery() {
        let searched = testItems.searched(query: "")
        XCTAssertEqual(searched.count, 4)
    }
    
    func testSortedByNameAscending() {
        let sorted = testItems.sorted(by: .nameAscending)
        XCTAssertEqual(sorted[0].name, "Apple")
        XCTAssertEqual(sorted[1].name, "Banana")
        XCTAssertEqual(sorted[2].name, "Bread")
        XCTAssertEqual(sorted[3].name, "Milk")
    }
    
    func testSortedByNameDescending() {
        let sorted = testItems.sorted(by: .nameDescending)
        XCTAssertEqual(sorted[0].name, "Milk")
        XCTAssertEqual(sorted[1].name, "Bread")
        XCTAssertEqual(sorted[2].name, "Banana")
        XCTAssertEqual(sorted[3].name, "Apple")
    }
    
    func testSortedByCreatedDate() async {
        let item1 = ShoppingItem(name: "First", quantity: 1)
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
        let item2 = ShoppingItem(name: "Second", quantity: 1)
        
        let items = [item2, item1]
        let sortedAsc = items.sorted(by: .createdDateAscending)
        let sortedDesc = items.sorted(by: .createdDateDescending)
        
        XCTAssertEqual(sortedAsc[0].name, "First")
        XCTAssertEqual(sortedAsc[1].name, "Second")
        XCTAssertEqual(sortedDesc[0].name, "Second")
        XCTAssertEqual(sortedDesc[1].name, "First")
    }
}

