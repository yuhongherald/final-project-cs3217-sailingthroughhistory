//
//  GenericEvaluateOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// The operator works in the notion of a BAE
protocol GenericOperator: Printable {
    associatedtype Type
    func evaluate(first: Type?, second: Type?) -> Type?
}
