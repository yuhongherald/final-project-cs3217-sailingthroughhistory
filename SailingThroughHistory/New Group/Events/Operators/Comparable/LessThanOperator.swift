//
//  LessThanOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class LessThanOperator<T>: GenericOperator where T: Comparable {
    var displayName: String { return "<" }
    func compare(first: Any?, second: Any?) -> Bool {
        guard let firstT = first as? T, let secondT = second as? T else {
            return false
        }
        return firstT < secondT
    }
}
