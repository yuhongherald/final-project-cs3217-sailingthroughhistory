//
//  VolatileMonsoon.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class that modifies the velocity of ships travelling through the paths it resides on.
 * Extend this class to create various monsoon behaviors, eg blow left/right
 */
class VolatileMonsoon: Volatile {
    var isActiveVariable: GameVariable<Bool> = GameVariable(value: false)
    override var isActive: Bool {
        get {
            return isActiveVariable.value
        }
        set {
            isActiveVariable.value = newValue
        }
    }
    override func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float {
        return oldVelocity * modifier * Float(GameConstants.monsoonMultiplier)
    }
}
