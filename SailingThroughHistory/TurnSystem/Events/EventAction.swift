//
//  EventAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * The base class for Actions. Sets the variable to be the value of the evaluatable.
 * Evaluatable supports BAE, allowing for complex evaluations.
 */
class EventAction<T>: Printable, Modify {
    var displayName: String = "action"

    private let variable: GameVariable<T>
    private let value: Evaluatable<T>

    init?(variable: GameVariable<T>?, value: Evaluatable<T>?) {
        guard let variable = variable, let value = value else {
            return nil
        }
        self.variable = variable
        self.value = value
    }

    func modify() {
        variable.value = value.value
    }
}
