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
    var playerTurn: PlayerTurn? = nil
    var currentGameTime: Double = 0
    var largestTimeStep: Double = GameConstants.largestTimeStep
    var forecastDuration: Double = GameConstants.forecastDuration
    var daysToSeconds: Double = GameConstants.daysToSeconds

    init(gameState: GameState) {
        self.gameState = gameState
    }

    
    func updateGameState(deltaTime: Double) {
        // TODO: Add player turn logic
        var timeDifference = deltaTime
        while (timeDifference > largestTimeStep) {
            // we break it into multiple cycles
            updateGameStateDeltatime(largestTimeStep)
            timeDifference -= largestTimeStep
        }
        updateGameStateDeltatime(timeDifference)
    }

    private func updateGameStateDeltatime(_ deltaTime: Double) {
        // TODO: Use the game state to update the game
    }
}
