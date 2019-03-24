//
//  GameLogicTest.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class EmotionEngineTest: XCTestCase {

    func testSetGameSpeed() {
        let logic = EmotionEngine(gameLogic: GameLogic(gameState: GameState(baseYear: 0)))
        var event = GameEvent(eventType: EventType.informative(initiater: ""), timestamp: 1, message: nil)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        event.timestamp = 1 * logic.forecastDuration
        logic.setGameSpeed(using: event)
        XCTAssertTrue(abs(logic.getGameSpeed() - logic.fastestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = 1.1 * logic.forecastDuration
        logic.setGameSpeed(using: event)
        XCTAssertTrue(abs(logic.getGameSpeed() - logic.fastestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = 0 * logic.forecastDuration
        logic.setGameSpeed(using: event)
        XCTAssertTrue(abs(logic.getGameSpeed() - logic.slowestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = -0.1 * logic.forecastDuration
        logic.setGameSpeed(using: event)
        XCTAssertTrue(abs(logic.getGameSpeed() -
                       Double.lerp(0.1 * logic.forecastDuration, logic.slowestGameSpeed,
                                   logic.fastestGameSpeed)) < 0.001, "Wrong game speed!")
        event.timestamp = 0.6 * logic.forecastDuration
        logic.setGameSpeed(using: event)
        XCTAssertTrue(abs(logic.getGameSpeed() -
                       Double.lerp(0.6 * logic.forecastDuration, logic.fastestGameSpeed,
                                   logic.slowestGameSpeed)) < 0.001, "Wrong game speed!")

    }

    func testUpdateGameState() {
        let gameState = GameLogic(gameState: GameState(baseYear: 0))
        let logic = EmotionEngine(gameLogic: gameState)
        logic.updateGameState(deltaTime: 1.0)
        // TODO: Write test to check months and weeks have been updated correctly
        // TODO: Write test to check that player movement have been done correctly
        // Bonus: Write test to check that game speed is set to tolerable bounds
    }
}
