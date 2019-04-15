//
//  EventTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventTrigger<T>: Printable, Trigger {
    var displayName: String = "trigger"

    private let variable: GameVariable<T>
    private let comparator: GenericComparator
    private var triggered: Bool = false
    private var oldValue: T

    init(variable: GameVariable<T>, comparator: GenericComparator) {
        self.variable = variable
        self.comparator = comparator
        self.oldValue = variable.value
        variable.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            self.triggered = self.triggered ||
                self.comparator.compare(first: self.oldValue,
                                        second: self.variable.value)
        }
    }

    func hasTriggered() -> Bool {
        return triggered
    }

    func resetTrigger() {
        triggered = false
    }
}
