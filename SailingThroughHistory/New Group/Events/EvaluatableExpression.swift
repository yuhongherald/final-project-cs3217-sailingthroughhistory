//
//  EvaluatableExpression.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EvaluatableExpression<T>: GenericEvaluatable {
    var first: GenericEvaluatable?
    var ops: GenericEvaluateOperator?
    var second: GenericEvaluatable?
    func evaluate() -> Any? {
        return ops?.evaluate(first: first?.evaluate(), second: second?.evaluate())
    }
}
