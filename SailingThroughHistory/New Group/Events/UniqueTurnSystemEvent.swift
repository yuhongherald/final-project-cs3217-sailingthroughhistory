//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// The base class for turn system events with auto-generated ids
class UniqueTurnSystemEvent: UniqueObject, TurnSystemEvent {
    var triggers: [ReadOnlyEventTrigger] = []
    var events: [ReadOnlyEventTrigger] = []
    var conditions: [ReadOnlyEventCondition] = []
    var actions: [ReadOnlyEventAction] = []
    private var observers: [Int: Observer] = [Int: Observer]()

    //private var a: Int
    func addObserver(observer: Observer) {
        observers[observer.identifier] = observer
    }

    func removeObserver(observer: Observer) {
        observers.removeValue(forKey: observer.identifier)
    }

    func notify(eventUpdate: EventUpdate?) {
        guard let oldValue = eventUpdate?.oldValue as? Bool,
            let newValue = eventUpdate?.newValue as? Bool,
            oldValue != newValue else {
            return
        }

        
    }
}
