//
//  GenericTurnSystem.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class that runs the game in a turn-based fashion.
 */
protocol GenericTurnSystem: class {
    var gameState: GenericGameState { get }
    var eventPresets: EventPresets? { get set }
    var messages: [GameMessage] { get set }
    func getPresetEvents() -> [PresetEvent]

    /// Attempts to roll a number for a player.
    /// - Parameters:
    ///     - player: Player who wants to roll a number.
    /// - Returns:
    ///     - The rolled number, and the ids of the nodes in range of the player.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func roll(for player: GenericPlayer) throws -> (Int, [Int])

    /// Attempts to select a movement destination for a player.
    /// - Parameters:
    ///     - nodeId: The id of the destination.
    ///     - player: Player who wants to move.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws

    /// Attempts to set the tax of a port for a player.
    /// - Parameters:
    ///     - portId: The id of the port
    ///     - amount: New tax amound
    ///     - player: Player who wants to set tax.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws

    /// Attempts to buy items for a player.
    /// - Parameters:
    ///     - itemParameter: The item type the player wants to purchase.
    ///     - quantity: The amount the player wants to purchase.
    ///     - player: Player who wants to buy an item.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func buy(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws

    /// Attempts to sell items for a player.
    /// - Parameters:
    ///     - itemParameter: The item type the player wants to sell.
    ///     - quantity: The amount the player wants to sell.
    ///     - player: Player who wants to sell an item.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func sell(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws

    /// Attempts to toggle an event for a player.
    /// - Parameters:
    ///     - eventId: The id of the event to toggle.
    ///     - enabled: The state to set the event to.
    ///     - player: Player who wants to toggle an event.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func toggle(eventId: Int, enabled: Bool, by player: GenericPlayer) throws

    /// Attempts to buy an upgrade for a player.
    /// - Parameters:
    ///     - upgrade: The upgrade to be purchased.
    ///     - player: Player who wants to buy an upgrade.
    /// - Returns:
    ///     - A message regarding the purchase of the upgrade.
    /// - Throws:
    ///     - PlayerActionError, why it cannot be done
    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage?

    /// Subscribes to the network's state.
    /// - Parameters:
    ///     - callback: Notifies the source on the new state.
    func subscribeToState(with callback: @escaping (TurnSystemNetwork.State) -> Void)

    /// Starts a new turn round for the game
    func startGame()
    /// Ends the current turn in GenericTurnSystemState and GenericTurnSystemNetwork.
    func endTurn()
    func acknowledgeTurnStart()
}
