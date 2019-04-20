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
        let inputController = TestClasses.createInputController(timer: 2)
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
        let inputController = TestClasses.createInputController(timer: 2)
        let player = inputController.data.gameState.getPlayers()[0]
        let otherPlayer = inputController.data.gameState.getPlayers()[1]
        inputController.startPlayerInput(from: player)
        sleep(2)
        XCTAssertEqual(inputController.network.state,
                       TurnSystemNetwork.State.waitPlayerInput(from: otherPlayer),
                       "Player 1's turn should be over!")
    }
}
