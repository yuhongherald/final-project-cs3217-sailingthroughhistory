//
//  Weather.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Weather: VolatileModifier {
    var isActive = false
    var windVelocity: Float = 0

    func applyVelocityModifier(to oldVelocity: Float) -> Float {
        if isActive {
            return oldVelocity + windVelocity
        } else {
            return oldVelocity
        }
    }

    mutating func update(currentMonth: Int) {
        /// TODO: Randomize wind.
        windVelocity = 0
    }
}
