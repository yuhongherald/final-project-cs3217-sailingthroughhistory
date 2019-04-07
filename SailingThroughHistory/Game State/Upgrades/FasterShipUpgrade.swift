//
//  FasterShipUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class FasterShipUpgrade: ShipChassis {
    override var name: String {
        return "Faster Ship"
    }
    override var cost: Int {
        return 1000
    }

    override func getNewCargoCapacity(baseCapacity: Int) -> Int {
        return baseCapacity * 0.7
    }

    override func getMovementModifier() -> Double {
        return 2
    }
}
