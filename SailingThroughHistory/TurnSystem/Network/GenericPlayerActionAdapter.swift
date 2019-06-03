//
//  GenericPlayerActionAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class that controls how PlayerActions are executed in the context of a
 * GenericTurnSystemNetwork.
 */
protocol GenericPlayerActionAdapter: class {
    /// Attempts to process the player's actions for a given player.
    /// - Parameters:
    ///     - action: The action to be executed.
    ///     - player: The player who wants to execute the action.
    /// - Returns:
    ///     - The message resulting from the action.
    /// - Throws:
    ///     - PlayerActionError, why is it not allowed.
    func process(action: PlayerAction, for player: GenericPlayer) throws -> GameMessage?

    /// Attempts to process the player's trade actions for a given player.
    /// - Parameters:
    ///     - tradeAction: The trade action to be executed.
    ///     - player: The player who wants to execute the action.
    /// - Returns:
    ///     - The message resulting from the action.
    /// - Throws:
    ///     - PlayerActionError, why is it not allowed.
    func handle(tradeAction: PlayerAction, by player: GenericPlayer) throws -> GameMessage?

    /// Attempts to process the player's tax setting actions for a given player.
    /// - Parameters:
    ///     - action: The tax setting action to be executed.
    ///     - player: The player who wants to execute the action.
    /// - Returns:
    ///     - The message resulting from the action.
    /// - Throws:
    ///     - PlayerActionError, why is it not allowed.
    func register(portTaxAction action: PlayerAction,
                  by player: GenericPlayer) throws -> GameMessage?

    /// Handles the setting of the tax using networkInfo
    func handleSetTax()

    /// Attempts to process the player's movement actions for a given player.
    /// - Parameters:
    ///     - player: The player who wants to execute the action.
    ///     - nodeId: The id of the node the player wants to move to
    ///     - isEnd: Whether the player will stop here.
    /// - Returns:
    ///     - The message resulting from the action.
    func playerMove(_ player: GenericPlayer, _ nodeId: Int, isEnd: Bool) -> GameMessage?
}
