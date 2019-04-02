//
//  GenericOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericOperator: GenericEvaluateOperator {
    func compare(first: Any?, second: Any?) -> Bool
}

extension GenericOperator {
    func evaluate(first: Any?, second: Any?) -> Any? {
        return compare(first: first, second: second)
    }
}
