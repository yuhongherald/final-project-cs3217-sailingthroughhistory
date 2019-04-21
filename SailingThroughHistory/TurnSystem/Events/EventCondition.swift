//
//  TurnCondition.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * The base class for conditions. Compares 2 evaluatables and returns a Boolean.
 * Evaluatables support BAE, allowing for complex evaluations.
 */
class EventCondition<T>: Printable, Evaluate {
    var displayName: String = "condition"

    private let firstEvaluatable: Evaluatable<T>
    private let secondEvaluatable: Evaluatable<T>
    private let changeOperator: GenericComparator

    init(first: Evaluatable<T>, second: Evaluatable<T>, change: GenericComparator) {
        self.firstEvaluatable = first
        self.secondEvaluatable = second
        self.changeOperator = change
    }

    func evaluate() -> Bool {
        return changeOperator.compare(first: firstEvaluatable,
                                      second: secondEvaluatable)
    }
}
