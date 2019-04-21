//
//  Pirate_WeatherEntity.swift
//  SailingThroughHistory
//
//  Created by henry on 25/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines interactions with pirates and weather.
import Foundation

protocol Pirate_WeatherEntity {
    func startPirateChase()
    func getWeatherModifier() -> Double
}
