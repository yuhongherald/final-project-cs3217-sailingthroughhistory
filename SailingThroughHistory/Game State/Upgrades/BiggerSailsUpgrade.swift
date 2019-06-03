//
//  BiggerSailsUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// An Auxiliary upgrade that causes the ship experience greater weather effects.
import Foundation

class BiggerSailsUpgrade: AuxiliaryUpgrade {
    override var type: UpgradeType {
        return .biggerSails
    }
    override var name: String {
        return "Bigger sails"
    }
    override var cost: Int {
        return 1000
    }

    override func getWeatherModifier() -> Double {
        return 2
    }
}
