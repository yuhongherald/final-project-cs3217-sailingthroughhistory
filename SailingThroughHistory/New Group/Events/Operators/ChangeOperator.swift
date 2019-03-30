//
//  TrueOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// equivalent to a change operator, since conditions check on value change
class ChangeOperator: GenericOperator {
    func compare(first: Any?, second: Any?) -> Bool {
        return true
    }
    var displayName: String { return "changed" }
}
