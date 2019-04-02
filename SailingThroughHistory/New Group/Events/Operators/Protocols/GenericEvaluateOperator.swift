//
//  GenericEvaluateOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// The operator works in the notion of a BAE
protocol GenericEvaluateOperator: Printable {
    func evaluate(first: Any?, second: Any?) -> Any?
}
