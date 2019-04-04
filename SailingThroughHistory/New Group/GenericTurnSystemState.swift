//
//  GenericTurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystemState {
    var currentTurn: Int { get }
    var gameState: GenericGameState { get }

    var currentPlayerIndex: Int { get set }

    var triggeredEvents: [TurnSystemEvent] { get }
    func addEvents(events: [TurnSystemEvent]) -> Bool
    func removeEvents(events: [TurnSystemEvent]) -> Bool
    func setEvents(events: [TurnSystemEvent]) -> Bool
    func turnFinished()
    func processed(action: PlayerAction, from player: GenericPlayer)
}
