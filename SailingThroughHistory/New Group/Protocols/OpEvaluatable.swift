//
//  OpEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol OpEvaluatable { // TODO: Replace most references with a something that has both
    var evaluators: [GenericEvaluateOperator] { get }
}
