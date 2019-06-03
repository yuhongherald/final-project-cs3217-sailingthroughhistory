//
//  ShipChassis.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents the base Ship Chassis upgrade for a ship. All Ship Chassis upgrades
/// should extend this. Upgrade costs are assumed to be non-negative. Affects Cargo
/// Capacity, Item Consumption and Ship Movement.
import Foundation

class ShipChassis: Upgrade {
    var name: String {
        return "Ship Chassis"
    }
    var cost: Int {
        return 0
    }
    var type: UpgradeType {
        return .baseShip
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
}
