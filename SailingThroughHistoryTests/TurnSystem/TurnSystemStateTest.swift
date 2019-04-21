//
//  TurnSystemStateTests.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class TurnSystemStateTest: XCTestCase {
    func testEvents() {
        let state = TestClasses.createTestState(numPlayers: 1)
        let first = TestClasses.createTestEvent(identifier: 0)
        let second = TestClasses.createPresetEvent(identifier: 1)
        let third = TestClasses.createTestEvent(identifier: 2)

        XCTAssertTrue(state.events.isEmpty, "Should be empty by default") // 0
        XCTAssertTrue(state.addEvents(events: [first]), "Should have no conflict")
        XCTAssertEqual(Set<Int>([0]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertFalse(state.addEvents(events: [first, second]), "SHould have conflict")
        XCTAssertEqual(Set<Int>([0, 1]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertTrue(state.removeEvents(events: [second]), "Should have no conflict")
        XCTAssertEqual(Set<Int>([0]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertFalse(state.removeEvents(events: [third]), "SHould have conflict")
        XCTAssertEqual(Set<Int>([0]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertTrue(state.setEvents(events: [second, third]), "Should have no conflict")
        XCTAssertEqual(Set<Int>([1, 2]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertTrue(state.setEvents(events: []), "Should have no conflict")
        XCTAssertEqual(Set<Int>([]), Set(Array(state.events.keys)), "SHould be the same")
        XCTAssertTrue(state.setEvents(events: [first]), "Should have no conflict")
        XCTAssertEqual(Set<Int>([0]), Set(Array(state.events.keys)), "SHould be the same")
    }

    func testTurnFinished() {
        let state = TestClasses.createTestState(numPlayers: 1)
        let currentTurn = state.currentTurn
        state.turnFinished()
        XCTAssertEqual(currentTurn + 1, state.currentTurn, "Turn should have incremented")
    }

    func testGetPresetEvents() {
        let state = TestClasses.createTestState(numPlayers: 1)
        let first = TestClasses.createTestEvent(identifier: 0)
        let second = TestClasses.createPresetEvent(identifier: 1)
        let third = TestClasses.createPresetEvent(identifier: 2)
        XCTAssertTrue(state.getPresetEvents().isEmpty, "Should be empty by default") // 0
        state.addEvents(events: [first])
        XCTAssertTrue(state.getPresetEvents().isEmpty, "Should be empty without presets") // 0
        state.addEvents(events: [second, third])
        XCTAssertEqual(Set([1, 2]),
        Set(state.getPresetEvents().map { $0.identifier }),
        "List should have both presets") // 2
        let presets = TestClasses.createEventPresets().getEvents()
        state.setEvents(events: presets)
        XCTAssertEqual(Set(presets.map { $0.identifier }),
        Set(state.getPresetEvents().map { $0.identifier }),
        "List should be complete with from table") // all
    }

    func testCheckForEvents() {
        let state = TestClasses.createTestState(numPlayers: 1)
        // simplified
        let first = TestClasses.createPresetEvent(identifier: 0)
        first.active = true
        state.addEvents(events: [first])
        XCTAssertEqual(state.checkForEvents().count, 1,
                       "Active preset should have triggered")
        XCTAssertFalse(first.active, "Active preset should have deactivated")
        XCTAssertTrue(state.checkForEvents().isEmpty, "Active preset should have deactivated")
    }

}
