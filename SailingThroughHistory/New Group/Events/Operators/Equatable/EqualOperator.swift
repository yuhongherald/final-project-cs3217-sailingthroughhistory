//
//  IntOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EqualOperator<T>: GenericOperator where T: Equatable {
    var displayName: String { return "==" }
    func compare(first: Any?, second: Any?) -> Bool {
        guard let firstT = first as? T, let secondT = second as? T else {
            return false
        }
        return firstT == secondT
    }
}
