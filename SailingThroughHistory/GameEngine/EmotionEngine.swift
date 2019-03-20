//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EmotionEngine: GenericTurnBasedGame {
    // TODO: Extract gameState into a protocol
    private let gameState: GenericGameLogic
    var playerTurn: PlayerTurn?
    var currentGameTime: Double = 0
    var largestTimeStep: Double = GameConstants.largestTimeStep
    var forecastDuration: Double = GameConstants.forecastDuration
    var daysToSeconds: Double = GameConstants.weeksToSeconds
    // used for controls
    var externalGameSpeed: Double = 1
    // used for emotion engine
    var fastestGameSpeed: Double = GameConstants.fastestGameSpeed
    var slowestGameSpeed: Double = GameConstants.slowestGameSpeed
    private var gameSpeed: Double = 1

    init(gameState: GenericGameLogic) {
        self.gameState = gameState
    }

    func updateGameState(deltaTime: Double) -> GenericGameEvent? {
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

    private func updateGameSpeed(_ deltaTime: Double) -> GenericGameEvent? {
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

    func setGameSpeed(using event: GenericGameEvent) {
        let eventTimeDifference = event.timestamp - currentGameTime
        var alpha: Double = 0
        if eventTimeDifference >= 0 {
            alpha = 1 - ((forecastDuration - eventTimeDifference) / forecastDuration)
        } else {
            alpha = ((forecastDuration + eventTimeDifference) / forecastDuration)
        }
        alpha = Double.clamp(alpha, 0, 1)
        gameSpeed = Double.lerp(alpha, fastestGameSpeed, slowestGameSpeed)
    }

    // for testing
    func getGameSpeed() -> Double {
        return gameSpeed
    }

    private func updateGameStateDeltatime(_ deltaTime: Double) -> GenericGameEvent? {
        // TODO: Use the game state to update the game
        //gameState.
        // move ships by interpolation
        // check when a player ship lands into a tile, create event if required
        // (Pirate, starvation, reached port)

        // TODO: Create a method to push copies of events onto a stack so that they can be evaluated for emotion engine
        // update sea, mark as dirty if weather changes
        // update ports, stub to change prices
        // update npcs, check they moved into a port, update port owner's money
        // update players, check they moved into a port
        // update pirates, check they moved into a player
        return nil
    }

}
