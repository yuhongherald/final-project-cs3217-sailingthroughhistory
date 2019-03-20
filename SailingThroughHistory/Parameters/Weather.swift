//
//  Weather.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Weather: VolatileModifier {
    static let windEffectMultiplier: CGFloat = 1

    var isActive = false
    var windVelocity = CGPoint.zero

    func applyVelocityModifier(to oldVelocity: CGPoint) -> CGPoint {
        if isActive {
            return oldVelocity + windVelocity * Weather.windEffectMultiplier
        } else {
            return oldVelocity
        }
    }

    mutating func update(currentMonth: Int) {
        /// TODO: Randomize wind.
        windVelocity = CGPoint.zero
    }
}
