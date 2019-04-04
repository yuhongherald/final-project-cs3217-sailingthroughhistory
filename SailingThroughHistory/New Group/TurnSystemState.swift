//
//  TurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// A class used to hold the state of the turn based game
class TurnSystemState: UniqueObject, GenericTurnSystemState {
    private var events: Set<TurnSystemEvent> = Set<TurnSystemEvent>()
    private var actionHistory = [(player: GenericPlayer, action: PlayerAction)]()
    let gameState: GenericGameState
    var currentPlayerIndex = 0
    var currentTurn: Int

    init(gameState: GenericGameState, joinOnTurn: Int) {
        self.gameState = gameState
        self.currentTurn = joinOnTurn
    }
    
    private var triggeredEventsDict: [Int: TurnSystemEvent] = [Int: TurnSystemEvent]()
    var triggeredEvents: [TurnSystemEvent] {
        return Array(triggeredEventsDict.values)
    }

    func addEvents(events: [TurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            if self.events.contains(event) {
                result = false
                continue
            }
            self.events.insert(event)
        }
        return result
    }
    func removeEvents(events: [TurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            if !self.events.contains(event) {
                result = false
                continue
            }
            self.events.remove(event)
        }
        return result
    }
    func setEvents(events: [TurnSystemEvent]) -> Bool {
        return removeEvents(events: Array(self.events))
            && addEvents(events: events)
    }

    func checkForEvents() -> Bool {
        var result = false
        for event in events {
            result = result || event.evaluateEvent()
        }
        return result
    }

    // TODO: Call these 2 methods
    func turnFinished() {
        currentTurn += 1
    }

    func processed(action: PlayerAction, from player: GenericPlayer) {
        actionHistory.append((player: player, action: action))
    }
}
