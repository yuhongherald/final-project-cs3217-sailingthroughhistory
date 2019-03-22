//
//  UpdatableSea.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableWeather: Updatable {
    var data: VisualAudioData? {
        get {
            let data = VisualAudioData(
                contextualData: ContextualData.animated(images: Resources.Weather.monsoon, startingFrame: 0, loopDuration: Double.infinity),
                sound: SoundData.none)
            return data
        }
    }

    private let location: Path
    private let weather: Weather

    init(location: Path, weather: Weather) {
        self.location = location
        self.weather = weather
    }

    func update() -> Bool {
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
