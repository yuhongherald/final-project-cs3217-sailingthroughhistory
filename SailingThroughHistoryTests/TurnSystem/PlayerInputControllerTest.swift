//
//  PlayerInputController.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import XCTest
@testable import SailingThroughHistory

class PlayerInputControllerTest: XCTestCase {
    func testCheckInputAllowed() {
        let inputController = TestClasses.createInputController(timer: 2) { }
        let player = inputController.data.gameState.getPlayers()[0]
        let otherPlayer = inputController.data.gameState.getPlayers()[1]
        inputController.network.state = TurnSystemNetwork.State.playerInput(
            from: player, endTime: TimeInterval(2))
        do {
            try inputController.checkInputAllowed(from: player)
        } catch {
            XCTFail("Should allow player 1 to go")
        }
        do {
            try inputController.checkInputAllowed(from: otherPlayer)
        } catch {
            return
        }
        XCTFail("Should not allow player 2 to go")
    }
    
    func testStartPlayerInput() {
        let expectation = XCTestExpectation(description: "End p1's turn")
        let inputController = TestClasses.createInputController(timer: 2) { expectation.fulfill() }
        let player = inputController.data.gameState.getPlayers()[0]
        let otherPlayer = inputController.data.gameState.getPlayers()[1]
        inputController.startPlayerInput(from: player)
        wait(for: [expectation], timeout: 3)
        switch inputController.network.state {
        case .waitPlayerInput(from: let player):
            XCTAssertEqual(player.deviceId, otherPlayer.deviceId,
                           "Player 1's turn should be over!")
        default:
            XCTFail("Wrong state!")
        }
    }
}
