//
//  EventTable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventTable {
    private var table: [Int: TurnSystemEvent] = [Int: TurnSystemEvent]()
    private var nextID: Int = 0
    func pushEvent(event: TurnSystemEvent) -> TurnSystemEvent {
        event.identifier = nextID
        table[nextID] = event
        nextID += 1
        return event
    }
    func getEvent(id: Int) -> TurnSystemEvent? {
        return table[id]
    }
}
