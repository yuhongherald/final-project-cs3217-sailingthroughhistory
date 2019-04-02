//
//  EventTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventTrigger: UniqueObject, ReadOnlyEventTrigger {

    // values for reference only, currently subscribing manually outside
    var objectIdentifier: SerializableGameObject?
    var objectField: String?

    var changeOperator: GenericOperator?

    private var observers: [Int: Observer] = [Int: Observer]()

    func notify(eventUpdate: EventUpdate?) {
        guard let result = changeOperator?.compare(first: eventUpdate?.oldValue,
                                      second: eventUpdate?.newValue), result else {
            return
        }
        var update = EventUpdate()
        update.oldValue = nil
        update.newValue = identifier

        for (identifier, observer) in observers {
            observer.notify(eventUpdate: update)
        }
    }

    func addObserver(observer: Observer) {
        observers[observer.identifier] = observer
    }

    func removeObserver(observer: Observer) {
        observers.removeValue(forKey: observer.identifier)
    }

}
