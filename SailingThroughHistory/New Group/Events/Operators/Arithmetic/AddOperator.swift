//
//  AddOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct AddOperator<T>: GenericOperator where T: Arithmetic {
    var displayName: String { return "+" }
    func evaluate(first: Any?, second: Any?) -> Any? {
        guard let firstT = first as? T, let secondT = second as? T else {
            return false
        }
        return firstT + secondT
    }
}
