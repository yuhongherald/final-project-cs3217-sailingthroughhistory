//
//  GenericGameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines the various behaviors that a Game State in the game needs to support.
/// Game State interacts with the TurnSystem and Level.
import Foundation

protocol GenericGameState: Codable, CustomStringConvertible {
    var gameTime: GameVariable<GameTime> { get set }
    var gameObjects: [GameObject] { get }
    var map: Map { get }
    var availableUpgrades: [Upgrade] { get }
    var maxTaxAmount: Int { get }
    var itemParameters: [GameVariable<ItemParameter>] { get set }
    var numTurns: Int { get }

    func getPlayers() -> [GenericPlayer]
    func startNextTurn(speedMultiplier: Double)
    func getNextPlayer() -> GenericPlayer?
    func getTeamMoney() -> [Team: Int]
    func distributeTeamMoney()
}
