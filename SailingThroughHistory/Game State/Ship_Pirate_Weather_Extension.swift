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
    func startPirateChase() -> InfoMessage {
        isChasedByPirates = true
        turnsToBeingCaught = 2
        return InfoMessage(title: "Pirates!",
                    message: "You have ran into pirates! You must dock your ship within \(turnsToBeingCaught) turns or risk losing all your cargo!")
    }
    func getWeatherModifier() -> Double {
        var multiplier = 1.0
        multiplier *= shipChassis?.getWeatherModifier() ?? 1
        multiplier *= auxiliaryUpgrade?.getWeatherModifier() ?? 1
        return multiplier
    }
}
