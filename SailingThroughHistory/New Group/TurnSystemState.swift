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
    private var objects: [Int: BaseGameObject] = [Int: BaseGameObject]()

    func addEvents(events: [ReadOnlyEventCondition]) -> Bool {
        var result: Bool = true
        for event in events {
            if events.contains(event) {
                result = false
                continue
            }
            self.events.insert(events)
        }
        return result
    }
    func removeEvents(events: [ReadOnlyEventCondition]) -> Bool {
        for event in events {
            
        }
        return true
    }
    func setEvents(events: [ReadOnlyEventCondition]) -> Bool {
        removeEvents(events: Array(self.events))
        addEvents(events: events)
        return true
    }
}
