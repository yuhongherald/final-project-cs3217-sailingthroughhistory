//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * The base class for events in TurnSystem, with a collection of triggers,
 * conditions and actions. Ids are expected to be managed manually.
 * The event runs the actions sequentially if:
 * evaluateEvent finds that it has been triggered, and all conditions evaluate to true.
 * Evaluating the event will reset the firing of all triggers.
 */
class TurnSystemEvent: Unique, Printable {
    var identifier: Int = -1

    let displayName: String

    let triggers: [Trigger]
    private let conditions: [Evaluate]
    private let actions: [Modify]
    private let parsable: () -> String

    init(triggers: [Trigger], conditions: [Evaluate],
         actions: [Modify?], parsable: @escaping () -> String, displayName: String) {
        self.triggers = triggers
        self.conditions = conditions
        self.actions = actions.compactMap({ $0 })
        self.parsable = parsable
        self.displayName = displayName
    }

    func evaluateEvent() -> GameMessage? {
        if !hasTriggered() {
            return nil
        }
        executeWithConditions()
        resetTrigger()
        return GameMessage.event(name: displayName, message: parsable())
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

    func resetTrigger() {
        for trigger in triggers {
            trigger.resetTrigger()
        }
    }
}
