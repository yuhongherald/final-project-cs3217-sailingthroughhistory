//
//  ConditionComparable.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ConditionComparable: ComparableOp {
    associatedtype SomeType where SomeType: Comparable
}

extension ConditionComparable {
    var operators: [GenericComparator] {
        return [
        EqualOperator<SomeType>(),
        NotEqualOperator<SomeType>(),
        LessThanOperator<SomeType>(),
        GreaterThanOperator<SomeType>(),
        LessThanOrEqualOperator<SomeType>(),
        GreaterThanOrEqualOperator<SomeType>(),
        TrueOperator()
        ]
    }
}
