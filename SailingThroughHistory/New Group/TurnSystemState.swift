//
//  TurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// A class used to hold the state of the turn based game
class TurnSystemState: GenericTurnSystemState {
    private var events: [Int: TurnSystemEvent] = [Int: TurnSystemEvent]()
    // TODO: Move this into a GameObject, technically it is a lot of fields
    private var objects: [Int: BaseGameObject] = [Int: BaseGameObject]()

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
}