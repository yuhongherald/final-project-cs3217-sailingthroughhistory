//
//  ObservableGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// gameobjects should all inherit from this
protocol BaseGameObject: SerializableGameObject {
    var events: [Int: Observer] { get set }
    var objects: [String: Any?] { get set }
    func addObserver(observer: Observer)
    func removeObserver(observer: Observer)
    func setField(field: String, object: Any?) -> Bool
}

extension BaseGameObject {
    func addObserver(observer: Observer) {
        if events[observer.identifier] != nil {
            return
        }
        events[observer.identifier] = observer
    }
    func removeObserver(observer: Observer) {
        events[observer.identifier] = nil
    }
    func getField(field: String) -> Any? {
        return objects[field]
    }
    func setField(field: String, object: Any?) -> Bool {
        if !fields.contains(field) {
            return false
        }
        for observer in events.values {
            observer.notify(eventUpdate: EventUpdate(oldValue: objects[field], newValue: object))
        }
        objects[field] = object

        return true
    }
}
