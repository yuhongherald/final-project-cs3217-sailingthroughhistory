//
//  TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol TurnBasedGame {
    var playerTurn: PlayerTurn? { get set }
    var currentGameTime: Double { get }
    /// Used to prevent event "tunneling"
    var largestTimeStep: Double { get set }
    /// The amount of time the game looks ahead for an event
    var forecastDuration: Double { get set }
    /// updates the game state by taking a timestep, recursively
    /// also returns the closest forecasted event, if any
    func updateGameState(deltaTime: Double)
}
