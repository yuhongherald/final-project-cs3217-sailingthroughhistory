//
//  TurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// A class used to hold the state of the turn based game
class TurnSystemState: GenericTurnSystemState {
    private var events: Set<UniqueTurnSystemEvent> = Set<UniqueTurnSystemEvent>()
    // TODO: Move this into a GameObject, technically it is a lot of fields
    private var objects: [Int: BaseGameObject] = [Int: BaseGameObject]()

    func addEvents(events: [UniqueTurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            if events.contains(event) {
                result = false
                continue
            }
            self.events.insert(event)
        }
        return result
    }
    func removeEvents(events: [UniqueTurnSystemEvent]) -> Bool {
        var result: Bool = true
        for event in events {
            guard self.events.remove(event) != nil else {
                result = false
                continue
            }
        }
        return result
    }
    func setEvents(events: [UniqueTurnSystemEvent]) -> Bool {
        return removeEvents(events: Array(self.events))
            && addEvents(events: events)
    }
}
