//
//  ShipPirateWeatherUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ShipPirateWeatherUnitTests: XCTestCase {
    var node = NodeStub(name: "testNode", identifier: 0)

    func testStartPirateChase() {
        let ship1 = Ship(node: node, itemsConsumed: [])
        ship1.isChasedByPirates = true
        ship1.turnsToBeingCaught = 1
        ship1.startPirateChase()
        XCTAssertEqual(ship1.isChasedByPirates, true)
        XCTAssertEqual(ship1.turnsToBeingCaught, 1)

        let ship2 = Ship(node: node, itemsConsumed: [])
        ship2.isChasedByPirates = false
        ship2.turnsToBeingCaught = 1
        ship2.startPirateChase()
        XCTAssertEqual(ship2.isChasedByPirates, true)
        XCTAssertEqual(ship2.turnsToBeingCaught, 4)
    }

    func testGetWeatherModifier() {
        let ship1 = Ship(node: node, itemsConsumed: [])
        XCTAssertEqual(ship1.getWeatherModifier(), 1.0)

        let ship2 = Ship(node: node, itemsConsumed: [])
        ship2.auxiliaryUpgrade = BiggerSailsUpgrade()
        XCTAssertEqual(ship2.getWeatherModifier(), BiggerSailsUpgrade().getWeatherModifier())
    }
}
