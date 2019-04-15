//
//  MultiplyOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct MultiplyOperator<T>: GenericOperator where T: Arithmetic {
    var displayName: String { return "*" }
    func evaluate(first: Any?, second: Any?) -> Any? {
        guard let firstT = first as? T, let secondT = second as? T else {
            return false
        }
        return firstT * secondT
    }
}
