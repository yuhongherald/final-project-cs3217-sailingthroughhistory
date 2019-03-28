//
//  ObservableGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// gameobjects should all inherit from this
protocol BaseGameObject: class, SerializableGameObject {
    var events: [Int: TurnSystemEvent] { get set }
    var objects: [String: AnyObject] { get set }
}

extension BaseGameObject {
    func addObserver(event: TurnSystemEvent) {
        if events[event.identifier] != nil {
            return
        }
        events[event.identifier] = event
    }
    func removeObserver(event: TurnSystemEvent) {
        events[event.identifier] = nil
    }
    func setField(field: String, object: Any) -> Bool {
        if !fields.contains(field) {
            return false
        }
        for (eventID, event) in events {
            event.notify(objects[field], object)
        }
        objects[field] = object
        return true
    }
}
