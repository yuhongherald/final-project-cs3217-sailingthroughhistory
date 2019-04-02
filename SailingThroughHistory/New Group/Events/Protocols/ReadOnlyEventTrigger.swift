//
//  ReadOnlyEventTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ReadOnlyEventTrigger: Observer, Observable {
    // some value changed
    // some value increased/decreased <- Evaluate using the operator
    var objectIdentifier: SerializableGameObject? { get }
    // return value is dependent on objectIdentifier
    var objectField: String? { get }
    
    var changeOperator: GenericOperator? { get }
}
