//
//  Arithmetic.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Arithmetic: Operatable {
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Self) -> Self
}

extension Arithmetic {
    var evaluators: [GenericOperator] {
        return [
            AddOperator<Self>(),
            SubtractOperator<Self>(),
            MultiplyOperator<Self>(),
            DivideOperator<Self>()
        ]
    }
}
