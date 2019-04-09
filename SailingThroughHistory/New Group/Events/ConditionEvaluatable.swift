//
//  ConditionEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ConditionEvaluatable<T>: Evaluatable<T> {
    override var value: T {
        get {
            for condition in conditions {
                guard condition.evaluate() else {
                    return falseValue.value
                }
            }
            return trueValue.value
        }
        set {
            // discarded
        }
    }
    private let conditions: [Evaluate]
    private let trueValue: Evaluatable<T>
    private let falseValue: Evaluatable<T>

    init(trueValue: Evaluatable<T>, falseValue: Evaluatable<T>,
         conditions: [Evaluate]) {
        self.conditions = conditions
        self.trueValue = trueValue
        self.falseValue = falseValue
        super.init(trueValue.value)
    }
}
