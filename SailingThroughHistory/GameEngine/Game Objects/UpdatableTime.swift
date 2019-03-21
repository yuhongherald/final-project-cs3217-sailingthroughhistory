//
//  UpdatableTime.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableTime: EngineObject, Updatable {

    var data: VisualAudioData? {
        get {
            return VisualAudioData(
                contextualData: ContextualData.message(message: "This is the game time"),
                sound: GameSound.none)
        }
    }

    func update() -> Bool {
        return false
    }
    
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
