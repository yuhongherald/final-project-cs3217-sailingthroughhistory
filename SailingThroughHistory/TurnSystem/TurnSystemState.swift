//
//  TurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * The default implementation of GenericTurnSystemState.
 */
class TurnSystemState: GenericTurnSystemState {
    private(set) var events: [Int: TurnSystemEvent] = [Int: TurnSystemEvent]()
    private var actionHistory = [(player: GenericPlayer, action: PlayerAction)]()
    let gameState: GenericGameState
    var currentPlayerIndex = 0
    var currentTurn: Int
    var messages: [GameMessage] = []

    init(gameState: GenericGameState, joinOnTurn: Int) {
        self.gameState = gameState
        self.currentTurn = joinOnTurn
    }

    private var triggeredEventsDict: [Int: TurnSystemEvent] = [Int: TurnSystemEvent]()
    var triggeredEvents: [TurnSystemEvent] {
        return Array(triggeredEventsDict.values)
    }

    func getPresetEvents() -> [PresetEvent] {
        return events.values.compactMap { $0 as? PresetEvent }
    }

    func addEvents(events: [TurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            if self.events[event.identifier] != nil {
                result = false
                continue
            }
            self.events[event.identifier] = event
        }
        return result
    }

    func removeEvents(events: [TurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            if self.events[event.identifier] == nil {
                result = false
                continue
            }
            self.events[event.identifier] = nil
        }
        return result
    }
    func setEvents(events: [TurnSystemEvent]) -> Bool {
        return removeEvents(events: Array(self.events.values))
            && addEvents(events: events)
    }

    func checkForEvents() -> [GameMessage] {
        var result = [GameMessage]()
        for (_, event) in events {
            guard let eventResult = event.evaluateEvent() else {
                continue
            }
            result.append(eventResult)
        }
        return result
    }

    func turnFinished() {
        currentTurn += 1
    }
}
