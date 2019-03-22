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

    func applyVelocityModifier(to oldVelocity: CGPoint) -> CGPoint
    func update(currentMonth: Int)
}

extension VolatileModifier {

    func applyVelocityModifier(to oldVelocity: CGPoint) -> CGPoint {
        return oldVelocity
    }

    func update(currentMonth: Int) { }
}
