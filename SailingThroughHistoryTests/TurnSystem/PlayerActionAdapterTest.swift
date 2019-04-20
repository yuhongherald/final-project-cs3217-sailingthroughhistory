//
//  PlayerActionAdapterTests.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class PlayerInputControllerTest: XCTestCase {
    func processTest() {
        let state = GameVariable<TurnSystemNetwork.State>(
            value: TurnSystemNetwork.State.invalid)
        let networkInfo = TestClasses.createNetworkInfo()
        let data = TestClasses.createTestState(numPlayers: 1)
        let adapter = PlayerActionAdapter(
            stateVariable: state,
            networkInfo: networkInfo,
            data: data)
        let player = data.gameState.getPlayers()[0]
        let otherPlayer = data.gameState.getPlayers()[1]
        guard let location = data.gameState.map.getNodes().filter({
            $0.identifier != player.node?.identifier }).first else {
                XCTFail("There should be 2 connected nodes on the test map")
                return
        }
        let playerAction = PlayerAction.move(toNodeId: location.identifier, isEnd: false)
        state.value = .invalid
        moveFail(adapter: adapter, playerAction: playerAction, player: player)
        state.value = .evaluateMoves(for: player)
        moveFail(adapter: adapter, playerAction: playerAction, player: otherPlayer)
        do {
            // not checking result
            _ = try adapter.process(action: playerAction, for: player)
        } catch {
            XCTFail("Player's move unable to be evaluated, wrong phase")
        }
    }
    
    private func moveFail(adapter: PlayerActionAdapter, playerAction: PlayerAction,
                          player: GenericPlayer) {
        do {
            _ = try adapter.process(action: playerAction, for: player)
        } catch {
            return
        }
        XCTFail("Player 2 should not be able to move!")
    }
    
    // not testing the other functionality
}
