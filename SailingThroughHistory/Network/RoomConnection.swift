//
//  Network.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/// Protocol for a connection to a network for a room.
protocol RoomConnection {

    /// Identifier of the room master device.
    var roomMasterId: String { get }

    /// Adds a player for this device
    func addPlayer()

    /// Starts and notifies all connected devices that the game has started
    ///
    /// - Parameters:
    ///   - initialState: The initial game state of the game.
    ///   - background: The data for the background image of the game.
    ///   - callback: callback to be called after the data has been uploaded
    /// - Throws: If GameState cannot be encoded.
    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws

    /// Pushes the current state into the network, for the given turn.
    ///
    /// - Parameters:
    ///   - currentState: The current state of the game.
    ///   - turn: The current turn number.
    ///   - callback: callback to be called after the data has been uploaded
    /// - Throws: If the GameState cannot be encoded.
    func push(currentState: GameState, forTurn turn: Int, completion callback: @escaping (Error?) -> Void) throws

    /// Subscribes to the player actions for the input turn. The callback will be called whenever the actions for that
    /// turn changes.
    ///
    /// - Parameters:
    ///   - turn: The turn number to listen to.
    ///   - callback: allback will be called whenever the actions for that turn changes.
    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    /// Subscribes to the members of the room. The callback will be called whenever the room members change.
    ///
    /// - Parameter callback: callback will be called whenever the room members change.
    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void)

    /// Push the actions for the current turn to the network.
    ///
    /// - Parameters:
    ///   - actions: PlayerActions to push
    ///   - player: player who carried out the actions
    ///   - turn: turn number
    ///   - callback: will be called once the data has been pushed to the network.
    /// - Throws: If actions cannot be encoded.
    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer,
              forTurnNumbered turn: Int,
              completion callback: @escaping (Error?) -> Void) throws

    /// Sets the teams of the room.
    ///
    /// - Parameter teams: The new teams of the room
    func set(teams: [Team])

    /// Subscibes to any change in team names of the room.
    ///
    /// - Parameter callback: called when team name changes and on initial subscribe.
    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void)

    /// Subscibes to start of the game.
    ///
    /// - Parameter callback: Called with game state and background image data when the game starts.
    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void)

    /// Change the team name of a player.
    ///
    /// - Parameters:
    ///   - identifier: The player's identifier
    ///   - teamName: The new team name for the player.
    /// - Throws: if the player information cannot be encoded.
    func changeTeamName(for identifier: String, to teamName: String) throws

    /// Change the name of a player.
    ///
    /// - Parameters:
    ///   - identifier: The player's identifier
    ///   - playerName: The new name of the player\
    /// - Throws: if the player information cannot be encoded.
    func changePlayerName(for identifier: String, to playerName: String) throws

    /// Remove player with the given identifier.
    ///
    /// - Parameter player: The identifier of the player to remove
    func remove(player: String)

    /// Get turn actions for a given turn.
    ///
    /// - Parameters:
    ///   - turn: The number of the turn
    ///   - callback: Called with the turn actions after they have been retrieved from the network.
    func getTurnActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    /// Change the callback to be called when this device has been removed from the room.
    ///
    /// - Parameter callback: the new callback
    func changeRemovalCallback(to callback: @escaping () -> Void)

    /// Subscribe to the state of the room master on the given turn.
    ///
    /// - Parameters:
    ///   - turn: The turn number
    ///   - callback: called with the master's game state whenever it changes and on subsciption.
    func subscribeToMasterState(for turn: Int, callback: @escaping (GameState) -> Void)

    /// Verifies if the string is a valid team or player name.
    ///
    /// - Parameter reference: The reference to verify
    func verify(reference: String) throws

    /// Disconnect from the network.
    func disconnect()
}
