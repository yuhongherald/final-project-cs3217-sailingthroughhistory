//
//  UpdatableSea.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableWeather: Updatable {
    static func == (lhs: UpdatableWeather, rhs: UpdatableWeather) -> Bool {
        return false
    }
    
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }

    let location: Node // will be replaced by an edge
    let weather: Weather

    init(location: Node, weather: Weather) {
        self.location = location
        self.weather = weather
    }

    func update(gameTime: Double) -> Bool {
        return false
    }
}
