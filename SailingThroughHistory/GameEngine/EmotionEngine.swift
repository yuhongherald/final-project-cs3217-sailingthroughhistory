//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EmotionEngine: GenericTurnBasedGame {
    private var gameLogic: GenericGameLogic
    var playerTurn: PlayerTurn? // TODO: marked for deletion
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

    init(gameLogic: GenericGameLogic, gameState: GenericGameState) {
        self.gameLogic = gameLogic
        self.gameLogic.gameState = gameState
    }

    func updateGameState(deltaTime: Double) -> CompoundGameEvent? {
        var timeDifference = deltaTime
        while timeDifference * gameSpeed * externalGameSpeed > largestTimeStep {
            // we break it into multiple cycles
            timeDifference -= largestTimeStep / gameSpeed / externalGameSpeed
            guard let events = updateGameSpeed(largestTimeStep) else {
                continue
            }
            return events
        }
        return updateGameSpeed(timeDifference * gameSpeed * externalGameSpeed)
    }

    private func updateGameSpeed(_ deltaTime: Double) -> CompoundGameEvent? {
        currentGameTime += deltaTime
        guard let events = updateGameStateDeltatime(deltaTime) else {
            return nil
        }
        let eventTimeDifference = events.timestamp - currentGameTime
        if eventTimeDifference <= 0 {
            // event has started
            return events
        }
        // interpolate the speed based on how close the event is to happening
        setGameSpeed(using: events)
        return nil
    }

    func setGameSpeed(using event: Timestampable) {
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

    private func updateGameStateDeltatime(_ deltaTime: Double) -> CompoundGameEvent? {
        var result = [GenericGameEvent]()
        for updatable in gameLogic.getUpdatables() {
            updatable.update(time: deltaTime)
        }
        guard result.count != 0 else {
            return nil
        }
        return CompoundGameEvent(events: result)
    }

}
