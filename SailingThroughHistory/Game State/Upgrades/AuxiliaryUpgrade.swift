//
//  AuxiliaryUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents the base Auxiliary upgrade for a ship. All Auxiliary upgrades
/// should extend this. Upgrade costs are assumed to be non-negative. Affects Item Consumption, Ship Movement and how much the ship is affected by weather.
import Foundation

class AuxiliaryUpgrade: Upgrade {
    var name: String {
        return "Auxiliary Upgrade"
    }
    var cost: Int {
        return 0
    }
    var type: UpgradeType {
        return .baseAuxillary
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
