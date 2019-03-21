//
//  UpdatableSea.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableWeather: Updatable {
    var status: DrawableStatus = DrawableStatus.add
    let location: Node // will be replaced by an edge
    let weather: Weather
    // weather contain edge or edge contain weather
    var gameObjectBox: GameObjectBox

    init(location: Node, weather: Weather, gameObject: GameObject) {
        self.gameObjectBox = GameObjectBox(gameObject: gameObject)
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
