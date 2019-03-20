//
//  CompoundGameEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct CompoundGameEvent: Timestampable {
    var timestamp: Double
    let events: [GenericGameEvent]

    init(events: [GenericGameEvent]) {
        self.events = events
        guard events.count != 0 else {
            self.timestamp = 0
            return
        }
        var timeStamp = events[0].timestamp
        for event in events {
            timeStamp = min(event.timestamp, timeStamp)
        }
        self.timestamp = timeStamp
    }
}
