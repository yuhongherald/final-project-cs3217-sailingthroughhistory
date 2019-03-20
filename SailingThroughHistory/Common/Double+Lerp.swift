//
//  Double+Lerp.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension Double {
    static func clamp(_ value: Double, _ lower: Double, _ upper: Double) -> Double {
        return max(min(value, upper), lower)
    }

    static func lerp(_ alpha: Double, _ lower: Double, _ upper: Double) -> Double {
        return alpha * lower + (1.0 - alpha) * upper
    }
}
