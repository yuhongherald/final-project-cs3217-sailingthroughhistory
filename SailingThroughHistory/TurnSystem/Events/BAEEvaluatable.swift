//
//  BAEEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class BAEEvaluatable<T>: Evaluatable<T> {
    private let first: Evaluatable<T>
    private let evaluator: GenericOperator
    private let second: Evaluatable<T>
    private var defaultValue: T
    override var value: T {
        get {
            return evaluator.evaluate(first: first.value, second: second.value) as? T ?? defaultValue
        }
        set {
            defaultValue = newValue
        }
    }

    init(first: Evaluatable<T>, second: Evaluatable<T>, evaluator: GenericOperator,
         defaultValue: T) {
        self.first = first
        self.second = second
        self.evaluator = evaluator
        self.defaultValue = defaultValue
        super.init(defaultValue)
    }
}
