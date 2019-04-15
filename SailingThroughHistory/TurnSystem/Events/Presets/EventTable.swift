//
//  EventTable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventTable<T> where T: TurnSystemEvent {
    private var table: [Int: T] = [Int: T]()
    private var nextID: Int = Int.max
    func pushEvent(event: T) -> T {
        event.identifier = nextID
        table[nextID] = event
        nextID -= 1
        return event
    }
    func getEvent(id: Int) -> T? {
        return table[id]
    }
    func getAllEvents() -> [T] {
        return Array(table.values)
    }
}
