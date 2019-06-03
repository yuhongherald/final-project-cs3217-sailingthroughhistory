//
//  RectTest.swift
//  SailingThroughHistoryTests
//
//  Created by Jason Chong on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class RectTest: XCTestCase {
    func testValueType() {
        /// This is needed as let keyword is used later to check if the rect has been modified.
        /// If rect is changed to a reference type, then the tests need to be changed
        XCTAssertNil(Rect() as? AnyClass,
                     "Reference type detected, code has to be changed to be compatible")
    }

    func testInit() {
        let rect = Rect()
        XCTAssertEqual(rect.height, 0, "Default initializer not working properly")
        XCTAssertEqual(rect.width, 0, "Default initializer not working properly")
        XCTAssertEqual(rect.originX, 0, "Default initializer not working properly")
        XCTAssertEqual(rect.originY, 0, "Default initializer not working properly")
        let rect2 = Rect(originX: 1, originY: 2, height: 3, width: 4)
        XCTAssertEqual(rect2.height, 3, "Initialized with wrong values")
        XCTAssertEqual(rect2.width, 4, "Initialized with wrong values")
        XCTAssertEqual(rect2.originX, 1, "Initialized with wrong values")
        XCTAssertEqual(rect2.originY, 2, "Initialized with wrong values")
    }

    func testMid() {
        let rect = Rect()
        XCTAssertEqual(rect.midX, 0, "Mid X is wrong with default rect")
        XCTAssertEqual(rect.midY, 0, "Mid Y is wrong with default rect")
        let rect2 = Rect(originX: 1, originY: 2, height: 3, width: 4)
        XCTAssertEqual(rect2.midX, 3, "Mid X is wrong")
        XCTAssertEqual(rect2.midY, 3.5, "Mid Y is wrong")
    }

    func testMove() {
        let rect = Rect() // Using let constant ensures that original rect is unchanged.
        let moved = rect.movedTo(originX: 5, originY: 1)
        XCTAssertEqual(moved.height, 0, "Move changed height")
        XCTAssertEqual(moved.width, 0, "Move changed width")
        XCTAssertEqual(moved.originX, 5, "Moved to wrong location")
        XCTAssertEqual(moved.originY, 1, "Moved to wrong location")

        let rect2 = Rect(originX: 1, originY: 2, height: 3, width: 4)
        let moved2 = rect2.movedTo(originX: 1, originY: 1)
        XCTAssertEqual(moved2.height, 3, "Move changed height")
        XCTAssertEqual(moved2.width, 4, "Move changed width")
        XCTAssertEqual(moved2.originX, 1, "Moved to wrong location")
        XCTAssertEqual(moved2.originY, 1, "Moved to wrong location")
    }
}
