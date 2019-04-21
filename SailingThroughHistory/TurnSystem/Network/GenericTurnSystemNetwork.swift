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

    /// Processes the actions
    /// - Parameters:
    ///     - stateVariable: A reference to the TurnSystemNetwork's state.
    ///     - networkInfo: Information about the network connection.
    ///     - data: The data which the PlayerActions take effect on.
    /// - Returns:
    ///     - The actionAdapter for the given context.
    func processNetworkTurnActions(forTurnNumber turnNum: Int,
                                   playerActionPairs: [(String, [PlayerAction])])

    func waitForTurnFinish()

    func endTurn()
}
