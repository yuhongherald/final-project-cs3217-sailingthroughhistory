//
//  Ship_Pirate_Weather_Extension.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// MARK: - Affected by Pirates and Weather
extension Ship: Pirate_WeatherEntity {
    func startPirateChase() {
        isChasedByPirates = true
        turnsToBeingCaught = 2
    }
    func getWeatherModifier() -> Double {
        var multiplier = 1.0
        multiplier *= shipChassis?.getWeatherModifier() ?? 1
        multiplier *= auxiliaryUpgrade?.getWeatherModifier() ?? 1
        return multiplier
    }
}
