//
//  EventAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventAction<T>: Printable, Modify {
    var displayName: String = "action"

    private let variable: GameVariable<T>
    private let value: Evaluatable<T>

    init(variable: GameVariable<T>, value: Evaluatable<T>) {
        self.variable = variable
        self.value = value
    }

    func modify() {
        variable.value = value.value
    }
}
