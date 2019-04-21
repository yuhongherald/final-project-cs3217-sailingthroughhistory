//
//  GenericTurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class used to hold the state of the turn based game
 */
protocol GenericTurnSystemState: class, GameMessenger {
    /// The current turn in the game
    var currentTurn: Int { get }
    /// The game's state
    var gameState: GenericGameState { get }
    /// Active events
    var events: [Int: TurnSystemEvent] { get }
    /// The current player's index.
    var currentPlayerIndex: Int { get set }
    var triggeredEvents: [TurnSystemEvent] { get }

    /// Adds a list of events to the active events.
    /// - Parameters:
    ///     - events: Events to be added.
    /// - Returns:
    ///     - Whether there is any conflict ids
    func addEvents(events: [TurnSystemEvent]) -> Bool

    /// Removes a list of events from the active events.
    /// - Parameters:
    ///     - events: Events to be removed.
    /// - Returns:
    ///     - Whether there is any missing ids
    func removeEvents(events: [TurnSystemEvent]) -> Bool

    /// Sets the active events.
    /// - Parameters:
    ///     - events: Events to be set.
    /// - Returns:
    ///     - Whether there is any conflict ids
    func setEvents(events: [TurnSystemEvent]) -> Bool

    /// Checks all the active events, then resets the trigger.
    /// - Returns:
    ///     - An array of messages from the triggering of events, in order.
    func checkForEvents() -> [GameMessage]

    func getPresetEvents() -> [PresetEvent]

    /// Finishes the current turn. Increments the turn number.
    func turnFinished()
}
