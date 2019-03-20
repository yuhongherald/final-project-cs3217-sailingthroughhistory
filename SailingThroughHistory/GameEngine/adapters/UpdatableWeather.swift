//
//  UpdatableSea.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableWeather: Updatable {
    let location: Node // will be replaced by an edge
    let weather: Weather
    // weather contain edge or edge contain weather

    init(location: Node, weather: Weather) {
        self.location = location
        self.weather = weather
    }

    func update(time: Double) -> Bool {
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
