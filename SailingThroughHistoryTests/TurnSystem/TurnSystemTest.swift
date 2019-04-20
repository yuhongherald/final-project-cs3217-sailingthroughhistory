//
//  TurnSystemTest.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class TurnSystemTest: XCTestCase {
    func testGetPresetEvents() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 0)
        guard let events = turnSystem.eventPresets?.getEvents() else {
            XCTFail("Turn system initialized without event presets")
            return
        }
        let otherEvents = turnSystem.getPresetEvents()
        XCTAssertEqual(events.map { $0.displayName }, otherEvents.map { $0.displayName }, "Events not same!")
    }
    
    func testStartGame() {
        let turnSystem0 = TestClasses.createTestSystem(numPlayers: 0)
        let turnSystem1 = TestClasses.createTestSystem(numPlayers: 1)
        let turnSystem2 = TestClasses.createTestSystem(numPlayers: 2)
        
         turnSystem0.startGame()
         XCTAssertEqual(turnSystem0.network.state, TurnSystemNetwork.State.waitForTurnFinish, "Wrong state for 0 players")
         turnSystem1.startGame()
         XCTAssertEqual(turnSystem1.network.state,
         TurnSystemNetwork.State.waitPlayerInput(
         from: turnSystem1.gameState.getPlayers()[0]),
         "Wrong state for 1 player")
         turnSystem2.startGame()
         XCTAssertEqual(turnSystem2.network.state,
         TurnSystemNetwork.State.waitPlayerInput(
         from: turnSystem2.gameState.getPlayers()[0]),
         "Wrong state for 2 players")
    }
    
    // to represent all the actions
    func testRoll() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 2)
        rollOnWrongState()
        turnSystem.startGame()
        do {
            _ = try turnSystem.roll(for: turnSystem.gameState.getPlayers()[0])
        } catch {
            XCTFail("Failed to roll the dice, wrong state")
        }
        turnSystem.endTurn()
        rollOnWrongState()
    }

    private func rollOnWrongState(turnSystem: TurnSystem) {
        do {
            _ = try turnSystem.roll(for: turnSystem.gameState.getPlayers()[0])
        } catch {
            return
        }
        XCTFail("Managed to roll the dice, on wrong state")
    }

    func testSubscribeToState() {
        let result = GameVariable<Bool>(value: false)
        let turnSystem = TestClasses.createTestSystem(numPlayers: 1)
        turnSystem.subscribeToState {_ in
            result.value = true
        }
        turnSystem.startGame()
        XCTAssertTrue(result.value, "Not notified on subscription!")
        result.value = false
        do {
            _ = try turnSystem.roll(for: turnSystem.gameState.getPlayers()[0])
        } catch {
            XCTFail("Failed to roll the dice, wrong state")
        }
        XCTAssertFalse(result.value, "Notified when there is no change!")
    }
    
    func testEndTurn() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 1)
        turnSystem.startGame()
        turnSystem.endTurn()
        XCTAssertEqual(turnSystem.state, TurnSystemNetwork.State.waitForTurnFinish,
                       "Should be waiting for turn to finish!")
    }
}
