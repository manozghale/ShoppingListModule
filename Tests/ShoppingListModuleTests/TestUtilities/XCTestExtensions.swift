//
//  XCTestExtensions.swift
//  ShoppingListModuleTests
//
//  Created by Manoj on 06/08/2025.
//

import Foundation
import XCTest

/// XCTest extensions for common testing patterns
extension XCTestCase {
    
    /// Assert that an async operation throws a specific error
    func XCTAssertThrowsAsyncError<T>(
        _ expression: @escaping () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown, but no error was thrown. \(message())", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
    
    /// Assert that an async operation does not throw
    func XCTAssertNoThrowAsync<T>(
        _ expression: @escaping () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
        } catch {
            XCTFail("Unexpected error thrown: \(error). \(message())", file: file, line: line)
        }
    }
    
    /// Wait for a condition to be true with timeout
    func waitForCondition(
        timeout: TimeInterval = 5.0,
        condition: @escaping () -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let startTime = Date()
        
        while !condition() && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if !condition() {
            XCTFail("Condition not met within timeout", file: file, line: line)
        }
    }
    
    /// Assert that a value is eventually equal to expected value
    func XCTAssertEventuallyEqual<T: Equatable>(
        _ expression: @escaping () -> T,
        _ expectedValue: T,
        timeout: TimeInterval = 5.0,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        await waitForCondition(timeout: timeout) {
            expression() == expectedValue
        }
        
        let actualValue = expression()
        XCTAssertEqual(actualValue, expectedValue, message(), file: file, line: line)
    }
    
    /// Assert that a boolean condition is eventually true
    func XCTAssertEventuallyTrue(
        _ expression: @escaping () -> Bool,
        timeout: TimeInterval = 5.0,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        await waitForCondition(timeout: timeout) {
            expression()
        }
        
        XCTAssertTrue(expression(), message(), file: file, line: line)
    }
}

