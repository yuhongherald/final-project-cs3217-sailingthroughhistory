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

    var isActive: Bool { get set }
    var hasActivated: Bool { get set }
    func notify(oldValue: Any, newValue: Any)
}

extension TurnSystemEvent {
    // TODO: Notify event conditions, move to event conditions
    func notify(oldValue: Any, newValue: Any) {
        if hasActivated {
            return
        }
        isActive = true
        hasActivated = true
    }
}
