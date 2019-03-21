//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EmotionEngine: GenericTurnBasedGame {
    var playerTurn: PlayerTurn? // TODO: marked for deletion
    var currentGameTime: Double = 0
    var largestTimeStep: Double = GameConstants.largestTimeStep
    var forecastDuration: Double = GameConstants.forecastDuration
    var daysToSeconds: Double = GameConstants.weeksToSeconds

    // used for controls, pausing, speeding up
    var externalGameSpeed: Double = 1
    // used for emotion engine
    var fastestGameSpeed: Double = GameConstants.fastestGameSpeed
    var slowestGameSpeed: Double = GameConstants.slowestGameSpeed

    private var gameSpeed: Double = 1

    private var updatableCache: AnyIterator<Updatable>?
    private var nextEvent: GenericGameEvent

    init() {
        self.nextEvent = GameEvent(eventType: EventType.informative(initiater: ""),
                                   timestamp: 0, message: "")
    }

    func updateGameState(deltaTime: Double) -> GenericGameEvent? {
        let update = finishCacheUpdates()
        guard update == nil else {
            return update
        }

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

    private func finishCacheUpdates() -> GenericGameEvent? {
        while let updatable = updatableCache?.next() {
            if updatable.update() {
                // TODO: mark as dirty in update
            }
            guard let event = updatable.checkForEvent() else {
                continue
            }
            return event
        }
        return nil
    }

    private func updateGameSpeed(_ deltaTime: Double) -> GenericGameEvent? {
        currentGameTime += deltaTime
        guard let event = updateGameStateDeltatime(deltaTime) else {
            updatableCache = nil
            return nil
        }
        let eventTimeDifference = event.timestamp - currentGameTime
        if eventTimeDifference <= 0 {
            // event has started
            return event
        }
        // interpolate the speed based on how close the event is to happening
        setGameSpeed(using: event)
        updatableCache = nil
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

    func invalidateCache() {
        updatableCache = nil
    }

    // for testing
    func getGameSpeed() -> Double {
        return gameSpeed
    }

    private func updateGameStateDeltatime(_ deltaTime: Double) -> GenericGameEvent? {
        updatableCache = nil//gameLogic.getUpdatables(deltaTime: deltaTime)
        return finishCacheUpdates()
    }

}
