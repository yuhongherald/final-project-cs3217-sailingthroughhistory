//
//  GenericPlayerInputController.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A protocol that manages the input time window for each player.
 */
protocol GenericPlayerInputController: class {
    /// Checks if a player can make a move.
    /// - Parameters:
    ///     - player: The player that wants to make a move.
    /// - Throws:
    ///     - PlayerActionError, why is it not allowed
    func checkInputAllowed(from player: GenericPlayer) throws

    /// Starts a player's movement phase.
    /// - Parameters:
    ///     - player: The player that wants to make a move.
    func startPlayerInput(from player: GenericPlayer)
}
