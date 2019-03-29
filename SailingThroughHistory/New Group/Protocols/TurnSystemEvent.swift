//
//  TurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol TurnSystemEvent: Unique, Observable {
    // conditions are and styled
    var conditions: [ReadOnlyEventCondition] { get }
    var actions: [ReadOnlyEventAction] { get }

    func isAllConditionsReady() -> Bool
    func resetConditions()
    func executeActions()
}

extension TurnSystemEvent {
    func isAllConditionsReady() -> Bool {
        for condition in conditions {
            guard condition.isActive else {
                return false
            }
        }
        return true
    }

    func resetConditions() {
        for condition in conditions {
            condition.isActive = false
        }
    }

    func executeActions() {
        for action in actions {
            action.modify()
        }
    }
}
