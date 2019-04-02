//
//  TurnCondition.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventCondition: UniqueObject, ReadOnlyEventCondition {
    var objectIdentifier: SerializableGameObject?
    var objectField: String?

    var changeOperator: GenericOperator?
    
    var otherIdentifier: SerializableGameObject?
    var otherObjectField: String?
}
