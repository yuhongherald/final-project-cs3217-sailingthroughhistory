//
//  BiggerShipUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// A Ship Chassis upgrade that gives a bigger cargo capacity at the cost of movement.
import Foundation

class BiggerShipUpgrade: ShipChassis {
    override var name: String {
        return "Bigger Ship"
    }
    override var cost: Int {
        return 1000
    }
    override var type: UpgradeType {
        return .biggerShip
    }
    override func getNewCargoCapacity(baseCapacity: Int) -> Int {
        return baseCapacity * 2
    }

    override func getMovementModifier() -> Double {
        return 0.8
    }
}
