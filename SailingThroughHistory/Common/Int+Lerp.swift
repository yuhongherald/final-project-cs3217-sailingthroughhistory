//
//  Int+Lerp.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension Int {
    static func clamp(_ value: Int, _ lower: Int, _ upper: Int) -> Int {
        if lower > value {
            return lower
        } else if upper < value {
            return upper
        }
        return value
    }
}
