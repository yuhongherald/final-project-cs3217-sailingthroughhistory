//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// The base class for turn system events with auto-generated ids
class TurnSystemEvent: UniqueObject {
    private let triggers: [EventTrigger<Any>]
    private let conditions: [EventCondition<Any>]
    private let actions: [EventAction<Any>]

    init(triggers: [EventTrigger<Any>], conditions: [EventCondition<Any>],
         actions: [EventAction<Any>]) {
        self.triggers = triggers
        self.conditions = conditions
        self.actions = actions
    }

    func evaluateEvent() -> Bool {
        if !hasTriggered() {
            return false
        }
        executeWithConditions()
        resetTrigger()
        return true
    }

    private func hasTriggered() -> Bool {
        for trigger in triggers {
            if trigger.hasTriggered() {
                return true
            }
        }
        return false
    }

    private func executeWithConditions() {
        for condition in conditions {
            if !condition.evaluate() {
                return
            }
        }
        for action in actions {
            action.modify()
        }
    }

    private func resetTrigger() {
        for trigger in triggers {
            trigger.resetTrigger()
        }
    }
}
