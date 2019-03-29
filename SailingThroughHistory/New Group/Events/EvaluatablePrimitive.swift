//
//  EvaluatablePrimitive.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EvaluatablePrimitive<T>: GenericEvaluatable {
    var value: T?
    func evaluate() -> Any? {
        return value
    }
}
