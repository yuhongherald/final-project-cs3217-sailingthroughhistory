//
//  EventAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ReadOnlyEventAction: class {
    var objectIdentifier: SerializableGameObject? { get }
    // return value is dependent on objectIdentifier
    var objectField: String? { get }
    var evaluatable: GenericEvaluatable? { get }

    func modify()
}
