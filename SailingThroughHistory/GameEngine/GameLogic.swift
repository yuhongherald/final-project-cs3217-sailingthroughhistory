//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: TurnBasedGame {
    // TODO: Extract gameState into a protocol
    private let gameState: GenericGameState
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

    init(gameState: GenericGameState) {
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
        var alpha: Double = 0
        if eventTimeDifference > 0 {
            alpha = (forecastDuration - eventTimeDifference) / forecastDuration
        } else {
            alpha = 1 - ((forecastDuration + eventTimeDifference) / forecastDuration)
        }
        alpha = Double.clamp(alpha, 0, 1)
        gameSpeed = Double.lerp(alpha, fastestGameSpeed, slowestGameSpeed)
    }

    func getGameSpeed() -> Double {
        return gameSpeed
    }

    private func updateGameStateDeltatime(_ deltaTime: Double) -> GameEvent? {
        // TODO: Use the game state to update the game
        //gameState.
        // move ships by interpolation
        // check when a player ship lands into a tile, create event if required
        // (Pirate, starvation, reached port)
        return nil
    }
}
