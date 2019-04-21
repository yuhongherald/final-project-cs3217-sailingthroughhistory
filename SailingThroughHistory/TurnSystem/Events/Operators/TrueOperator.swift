//
//  TrueOperator.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An operator that returns true regardless of inputs.
 */
class TrueOperator: GenericComparator {
    func compare(first: Any?, second: Any?) -> Bool {
        return true
    }
    var displayName: String { return "changed" }
}
