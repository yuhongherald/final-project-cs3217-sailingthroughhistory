//
//  GameEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ReadOnlyEventCondition {
    var objectIdentifier: SerializableGameObject? { get }
    // return value is dependent on objectIdentifier
    var objectField: String? { get }

    var changeOperator: GenericOperator? { get }

    var otherIdentifier: SerializableGameObject? { get }
    var otherObjectField: String? { get }
}
