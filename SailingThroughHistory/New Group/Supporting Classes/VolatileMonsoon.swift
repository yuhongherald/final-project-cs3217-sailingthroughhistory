//
//  VolatileMonsoon.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// extend this class to create various monsoon behaviors, eg blow left/right
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
    func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float {
        return oldVelocity * modifier * GameConstants.monsoonMultiplier
    }
}
