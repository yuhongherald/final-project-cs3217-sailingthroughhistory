//
//  TurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// TODO: Do memory management in deinit
protocol TurnSystemEvent: Observable, Observer {
    // triggers are or styled
    var triggers: [ReadOnlyEventTrigger] { get }
    // conditions are and styled
    var conditions: [ReadOnlyEventCondition] { get }
    var actions: [ReadOnlyEventAction] { get }
    func executeActions()
}

extension TurnSystemEvent {

    func executeActions() {
        for action in actions {
            action.modify()
        }
    }
}
