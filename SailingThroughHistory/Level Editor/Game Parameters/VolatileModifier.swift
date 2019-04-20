//
//  VolatileModifier.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

protocol VolatileModifier: Codable {
    var isActive: Bool { get }

    func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float
    func update(currentMonth: Int)
}

// Generic class inheritate from VolatileModifier to force subclasses conform to codable
class Volatile: VolatileModifier, Codable {
    var isActive = false

    func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float {
        return oldVelocity
    }

    func update(currentMonth: Int) {
    }
}
