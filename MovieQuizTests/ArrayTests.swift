//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Simon Butenko on 25.02.2024.
//

@testable import MovieQuiz
import XCTest

final class ArrayTests: XCTestCase {
    /// Тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]

        let value = array[safe: 2]

        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }

    /// Тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]

        let value = array[safe: 20]

        XCTAssertNil(value)
    }
}
