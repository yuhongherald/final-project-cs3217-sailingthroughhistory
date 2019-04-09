//
//  GameVariableEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameVariableEvaluatable<T>: Evaluatable<T> {
    private let variable: GameVariable<T>
    override var value: T {
        get {
            return variable.value
        }
        set {
            variable.value = newValue
        }
    }
    init(variable: GameVariable<T>) {
        self.variable = variable
        super.init(variable.value)
    }
}
