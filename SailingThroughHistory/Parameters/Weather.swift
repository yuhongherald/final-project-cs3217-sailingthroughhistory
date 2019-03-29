//
//  Weather.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Weather: Volatile {
    var windVelocity: Float = 0

    func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float {
        if isActive {
            return oldVelocity + windVelocity
        } else {
            return oldVelocity
        }
    }

    func update(currentMonth: Int) {
        /// TODO: Randomize wind.
        windVelocity = 0
    }
}
