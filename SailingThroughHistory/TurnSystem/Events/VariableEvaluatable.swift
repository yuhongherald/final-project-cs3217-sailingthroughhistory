//
//  VariableEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 3/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * Evalutes the Variables value.
 */
class VariableEvaluatable<T>: Evaluatable<T> {
    private var variable: GameVariable<T>
    override var value: T {
        get {
            return variable.value
        }
        set {
            variable.value = newValue
        }
    }
    init(_ variable: GameVariable<T>) {
        self.variable = variable
        super.init(variable.value) // dummy value
    }
}
