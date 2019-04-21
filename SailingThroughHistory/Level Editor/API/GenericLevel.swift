//
//  GenericLevel.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * Protocol for setting of initial state of the game.
 */
protocol GenericLevel {
    /// Maximum tax of a port.
    var maxTaxAmount: Int { get }
    /// Default tax of a port.
    var defaultTaxAmount: Int { get }
    /// Upgrades that players can buy for their ship. Upgard types are predefined.
    var upgrades: [Upgrade] { get }
    /// Initial state of players. Including the initial amount of money.
    var playerParameter: [PlayerParameter] { get set }
    /// States of items. Including buy and sell price at each port, unit weight, and item types.
    var itemParameters: [ItemParameter] { get set }
    /// Teams of the game level.
    var teams: [Team] { get set }
    /// The number of turns to end the game.
    var numOfTurn: Int { get set }
    /// Time limit for each turn, i.e. after exhausting time limit, the next turn will start automatically.
    var timeLimit: Int { get set }
    /// Map for the level. Including nodes, paths and other position related information.
    var map: Map { get }

    init(map: Map, teams: [String])
}
