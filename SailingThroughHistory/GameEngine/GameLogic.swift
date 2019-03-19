//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: TurnBasedGame {
    // TODO: Extract gameState into a protocol
    private let gameState: GameState
    var playerTurn: PlayerTurn?
    var currentGameTime: Double = 0
    var largestTimeStep: Double = GameConstants.largestTimeStep
    var forecastDuration: Double = GameConstants.forecastDuration
    var daysToSeconds: Double = GameConstants.daysToSeconds
    // used for controls
    var externalGameSpeed: Double = 1
    // used for emotion engine
    var fastestGameSpeed: Double = GameConstants.fastestGameSpeed
    var slowestGameSpeed: Double = GameConstants.slowestGameSpeed
    private var gameSpeed: Double = 1

    init(gameState: GameState) {
        self.gameState = gameState
    }

    func updateGameState(deltaTime: Double) -> GameEvent? {
        var timeDifference = deltaTime
        while timeDifference * gameSpeed * externalGameSpeed > largestTimeStep {
            // we break it into multiple cycles
            timeDifference -= largestTimeStep / gameSpeed / externalGameSpeed
            guard let event = updateGameSpeed(largestTimeStep) else {
                continue
            }
            return event
        }
        return updateGameSpeed(timeDifference * gameSpeed * externalGameSpeed)
    }

    private func updateGameSpeed(_ deltaTime: Double) -> GameEvent? {
        currentGameTime += deltaTime
        guard let event = updateGameStateDeltatime(deltaTime) else {
            gameSpeed = fastestGameSpeed
            return nil
        }
        let eventTimeDifference = event.timestamp - currentGameTime
        if eventTimeDifference <= 0 {
            // event has started
            return event
        }
        // interpolate the speed based on how close the event is to happening
        setGameSpeed(using: event)
        return nil
    }

    func setGameSpeed(using event: GameEvent) {
        let eventTimeDifference = event.timestamp - currentGameTime
        let alpha = (forecastDuration - eventTimeDifference) / forecastDuration
        gameSpeed = alpha * fastestGameSpeed + (1.0 - alpha) * slowestGameSpeed
    }

    private func updateGameStateDeltatime(_ deltaTime: Double) -> GameEvent? {
        // TODO: Use the game state to update the game
        //gameState.
        return nil
    }
}
