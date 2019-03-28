//
//  ConditionComparable.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ConditionComparable: Operatable {
    associatedtype T where T: Comparable
}

extension ConditionComparable {
    var operators: [GenericOperator] {
        return [
        EqualOperator<T>(),
        NotEqualOperator<T>(),
        LessThanOperator<T>(),
        GreaterThanOperator<T>(),
        LessThanOrEqualOperator<T>(),
        GreaterThanOrEqualOperator<T>(),
        ChangeOperator()
        ]
    }
}
