//
//  TurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol TurnSystemEvent: class {
    var identifier: Int { get }
    // conditions are and styled
    var conditions: [ReadOnlyEventCondition] { get }
    var actions: [EventAction] { get }
}
