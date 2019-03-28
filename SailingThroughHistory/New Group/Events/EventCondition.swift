//
//  TurnCondition.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventCondition: ReadOnlyEventCondition {
    var hasActivated: Bool = false
    var isActive: Bool = false

    var objectIdentifier: SerializableGameObject?
    var objectField: String?

    var changeOperator: GenericOperator?
    
    var otherIdentifier: SerializableGameObject?
    var otherObjectField: String?

    init(something: Any) {
        // save a pointer to the game state
        // TODO: Move this into a factory method, shouldn't have so many nils
    }

    func getObjects() -> [SerializableGameObject]? {
        return []
    }

    func notify(eventUpdate: EventUpdate) {
        if hasActivated {
            return
        }
        // evaluate the condition
        guard let objectField = objectField, let otherObjectField = otherObjectField, let result = changeOperator?.compare(
            first: objectIdentifier?.getField(field: objectField),
            second: otherIdentifier?.getField(field: otherObjectField)) else {
                return
        }
        if result {
            isActive = true
            hasActivated = true
        }
    }
}
