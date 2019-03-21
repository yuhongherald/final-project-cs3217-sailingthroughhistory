//
//  UpdatableSea.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableWeather: EngineObject, Updatable {
    var data: ContextualData {
        get {
            return ContextualData.animated(images: weather.images)
        }
    }
    private let location: Path
    private let weather: Weather

    init(location: Path, weather: Weather) {
        self.location = location
        self.weather = weather
        super.init()
    }

    func update() -> Bool {
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
