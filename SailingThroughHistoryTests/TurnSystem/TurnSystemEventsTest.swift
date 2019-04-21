//
//  TurnSystemEventsTests.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory
import SailingThroughHistory

/*
class TurnSystemEventsTest: XCTest {
    func testTaxChangeEvent() {
        let state = TestClasses.createTestState(numPlayers: 1)
        let gameState = state.gameState
        let event = TaxChangeEvent(gameState: gameState,
                                   genericOperator: AddOperator<Int>(), modifier: 1)
        // get all the ports not owned by any player
        let neutralPorts = getAllNeutralPorts(gameState: gameState)
        var taxes: [Int: Int] = [Int: Int]()
        // check the tax
        for port in neutralPorts {
            taxes[port.identifier] = port.taxAmount.value
        }
        event.active = true
        // run event check
        _ = state.checkForEvents()
        // check the tax again
        for port in neutralPorts {
            // assume no change in ownership
            guard let tax = taxes[port.identifier] else {
                XCTFail("Port tax value is missing")
                break
            }
            XCTAssertEqual(tax + 1, port.taxAmount.value, "Port tax value reflected wrongly!")
        }
    }
    
    private func getAllNeutralPorts(gameState: GenericGameState) -> [Port] {
        var result: [Port] = []
        for rawPort in gameState.map.getNodes() {
            guard let port = rawPort as? Port, port.owner == nil else {
                continue
            }
            result.append(port)
        }
        return result
    }

}
*/
