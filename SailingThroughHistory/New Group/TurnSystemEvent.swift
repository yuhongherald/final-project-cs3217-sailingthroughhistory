//
//  GameEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// TODO: Implement, do protocol
protocol TurnSystemEvent {
    var objectIdentifier: ReadOnlyGameObject { get }

    // return value is dependent on objectIdentifier
    var objectField: String { get } // TODO

    var changeOperator: GenericOperator { get }

    var otherIdentifier: ReadOnlyGameObject { get }
    var otherObjectField: String { get } // TODO
}
