//
//  ShipChassis.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ShipChassis: Upgrade {
    var name: String {
        return "Ship Chassis"
    }
    var cost: Int {
        return 0
    }

    func getNewCargoCapacity(baseCapacity: Int) -> Int {
        return baseCapacity
    }
    
    func getNewSuppliesConsumed(baseConsumption: [GenericItem]) -> [GenericItem] {
        return baseConsumption
    }

    func getMovementModifier() -> Double {
        return 1.0
    }

    func getWeatherModifier() -> Double {
        return 1.0
    }

}
