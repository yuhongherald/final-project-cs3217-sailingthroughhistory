//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// The base class for turn system events with auto-generated ids
class UniqueTurnSystemEvent: UniqueObject, TurnSystemEvent {
    var conditions: [ReadOnlyEventCondition] = []
    var actions: [EventAction] = []
}
