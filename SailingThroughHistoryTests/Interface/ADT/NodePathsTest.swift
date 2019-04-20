//
//  ObjectPathTest.swift
//  SailingThroughHistoryTests
//
//  Created by Jason Chong on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class NodePathsTest: XCTestCase {
    private let testNode1 = Node(name: "testnode1", frame: Rect())
    private let testNode2 = Node(name: "testnode2", frame: Rect())
    private let testNode3 = Node(name: "testnode3", frame: Rect())
    private lazy var testPath1 = Path(from: testNode1, to: testNode2)
    private lazy var testPath2 = Path(from: testNode2, to: testNode3)
    private lazy var testPathReflexive = Path(from: testNode1, to: testNode1)

    func testInit() {
        _ = NodePaths()
    }

    func testAdd() {
        var paths = NodePaths()
        paths.add(path: testPath1)
        XCTAssertTrue(paths.contains(path: testPath1), "Path not added properly")
        XCTAssertEqual(paths.allPaths.count, 1, "Path was added more or less than once")
        paths.add(path: testPath2)
        XCTAssertTrue(paths.contains(path: testPath2), "Path not added properly")
        XCTAssertTrue(paths.contains(path: testPath1), "Previously added path was removed.")
        XCTAssertEqual(paths.allPaths.count, 2, "Path was not added properly")
        paths.add(path: testPathReflexive)
        XCTAssertTrue(paths.contains(path: testPathReflexive), "Path not added properly")
        XCTAssertTrue(paths.contains(path: testPath1), "Previously added path was removed.")
        XCTAssertTrue(paths.contains(path: testPath2), "Previously added path was removed.")
        XCTAssertEqual(paths.allPaths.count, 3, "Path was not added properly")
        paths.add(path: testPath1)
        XCTAssertTrue(paths.contains(path: testPath1), "Path not added properly")
        XCTAssertTrue(paths.contains(path: testPathReflexive), "Previously added path was removed.")
        XCTAssertTrue(paths.contains(path: testPath2), "Previously added path was removed.")
        XCTAssertEqual(paths.allPaths.count, 3, "Duplicate path was not handled properly")
    }

    func testRemove() {
        var paths = NodePaths()
        paths.add(path: testPath1)
        paths.add(path: testPath2)
        paths.add(path: testPathReflexive)
        paths.remove(path: testPathReflexive)
        XCTAssertFalse(paths.contains(path: testPathReflexive), "Reflexive path not removed properly")
        XCTAssertEqual(paths.allPaths.count, 2, "Path was not removed properly")
        paths.remove(path: testPath2)
        XCTAssertFalse(paths.contains(path: testPath2), "Reflexive path not removed properly")
        XCTAssertEqual(paths.allPaths.count, 1, "Path was not removed properly")
        paths.remove(path: testPath1)
        XCTAssertFalse(paths.contains(path: testPath1), "Reflexive path not removed properly")
        XCTAssertEqual(paths.allPaths.count, 0, "Path was not removed properly")
    }

    func testAddRemove() {
        var paths = NodePaths()
        paths.add(path: testPath1)
        paths.add(path: testPath2)
        paths.add(path: testPathReflexive)
        paths.remove(path: testPathReflexive)
        paths.add(path: testPathReflexive)
        XCTAssertTrue(paths.contains(path: testPathReflexive), "Reflexive path not added properly")
        XCTAssertEqual(paths.allPaths.count, 3, "Path was not added properly")
    }

    /// contains and allPaths were implicitly tested in the above cases.
}
