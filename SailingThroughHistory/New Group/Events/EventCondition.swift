//
//  TurnCondition.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventCondition: UniqueObject, ReadOnlyEventCondition {
    var isActive: Bool = false

    var objectIdentifier: SerializableGameObject?
    var objectField: String?

    var changeOperator: GenericOperator?
    
    var otherIdentifier: SerializableGameObject?
    var otherObjectField: String?

    func notify(eventUpdate: EventUpdate?) {
        if isActive {
            return
        }
        // evaluate the condition
        guard let objectField = objectField, let otherObjectField = otherObjectField, let result = changeOperator?.compare(
            first: objectIdentifier?.getField(field: objectField),
            second: otherIdentifier?.getField(field: otherObjectField)) else {
                return
        }
        isActive = result
    }
}
