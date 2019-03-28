//
//  GenericOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericOperator: Printable {
    func compare(first: Any?, second: Any?) -> Bool
}
