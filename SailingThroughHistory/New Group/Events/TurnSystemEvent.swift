//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// The base class for turn system events with auto-generated ids
class TurnSystemEvent: UniqueObject, Printable {
    private let _displayName: String
    var displayName: String {
        return _displayName
    }
    
    private let triggers: [Trigger]
    private let conditions: [Evaluate]
    private let actions: [Modify]

    init(triggers: [Trigger], conditions: [Evaluate],
         actions: [Modify], displayName: String) {
        self.triggers = triggers
        self.conditions = conditions
        self.actions = actions
        self._displayName = displayName
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
