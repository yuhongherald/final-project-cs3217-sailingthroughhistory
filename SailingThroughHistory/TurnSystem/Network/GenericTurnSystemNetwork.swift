//
//  GenericTurnSystemNetwork.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class used to manage the interfacing of the underlying network with the
 * GenericTurnSystem.
 */
protocol GenericTurnSystemNetwork: class {
    /// Actions that are waiting to be pushed onto the network.
    var pendingActions: [PlayerAction] { get set }
    /// A class that holds the reference to the state.
    var stateVariable: GameVariable<TurnSystemNetwork.State> { get }
    var state: TurnSystemNetwork.State { get set }
    /// The underlying data used for the game.
    var data: GenericTurnSystemState { get }
    /// The current active player.
    var currentPlayer: GenericPlayer? { get }

    /// Gets the player following the current player
    func getNextPlayer() -> GenericPlayer?
    /// Gets the first player in a turn
    func getFirstPlayer() -> GenericPlayer?

    /// Processes the actions from the network and appends the corresponding messages to
    /// data.
    /// - Parameters:
    ///     - turnNum: The turn which the action is performed
    ///     - playerActionPairs: The actions made by each player.
    func processNetworkTurnActions(forTurnNumber turnNum: Int,
                                   playerActionPairs: [(String, [PlayerAction])])

    /// Waits for the other players on the network to finish their turn
    func waitForTurnFinish()

    /// Ends the current player's turn
    func endTurn()
}
