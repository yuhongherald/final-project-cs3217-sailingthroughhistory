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

    func testUpdateGameState() {
        let gameState = GameEngineTypicalClasses.getTypicalGameState()
        // TODO: Add stuff into the game state here
        let emotionEngine = EmotionEngine(gameLogic: GameLogic(gameState: gameState))
        var timeDiff = 1.0
        let stopwatch = Stopwatch(smallestInterval: EngineConstants.smallestEngineTick)
        stopwatch.start()
        while stopwatch.getTimestamp() < 2.0 && timeDiff > 0 {
            timeDiff = 1.0 - emotionEngine.currentGameTime
            emotionEngine.updateGameState(deltaTime: timeDiff)
            // TODO: Monitor the game state here
        }
        // TODO: Write test to check months and weeks have been updated correctly
        // TODO: Write test to check that player movement have been done correctly
        // Bonus: Write test to check that game speed is set to tolerable bounds
        if stopwatch.getTimestamp() >= 2.0 {
            XCTFail("Too inefficient!")
        }
        stopwatch.stop()
    }

    func testSetGameSpeed() {
        let emotionEngine = EmotionEngine(gameLogic: GameLogic(gameState:
            GameEngineTypicalClasses.getTypicalGameState()))
        var event = GameEvent(eventType: EventType.informative(initiater: ""), timestamp: 1, message: nil)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        event.timestamp = 1 * emotionEngine.forecastDuration
        emotionEngine.setGameSpeed(using: event)
        XCTAssertTrue(abs(emotionEngine.getGameSpeed() - emotionEngine.fastestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = 1.1 * emotionEngine.forecastDuration
        emotionEngine.setGameSpeed(using: event)
        XCTAssertTrue(abs(emotionEngine.getGameSpeed() - emotionEngine.fastestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = 0 * emotionEngine.forecastDuration
        emotionEngine.setGameSpeed(using: event)
        XCTAssertTrue(abs(emotionEngine.getGameSpeed() - emotionEngine.slowestGameSpeed) < 0.001, "Wrong game speed!")
        event.timestamp = -0.1 * emotionEngine.forecastDuration
        emotionEngine.setGameSpeed(using: event)
        XCTAssertTrue(abs(emotionEngine.getGameSpeed() -
                       Double.lerp(0.1 * emotionEngine.forecastDuration, emotionEngine.slowestGameSpeed,
                                   emotionEngine.fastestGameSpeed)) < 0.001, "Wrong game speed!")
        event.timestamp = 0.6 * emotionEngine.forecastDuration
        emotionEngine.setGameSpeed(using: event)
        XCTAssertTrue(abs(emotionEngine.getGameSpeed() -
                       Double.lerp(0.6 * emotionEngine.forecastDuration, emotionEngine.fastestGameSpeed,
                                   emotionEngine.slowestGameSpeed)) < 0.001, "Wrong game speed!")

    }
}
