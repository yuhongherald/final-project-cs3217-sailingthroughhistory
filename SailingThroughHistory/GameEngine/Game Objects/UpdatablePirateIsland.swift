//
//  UpdatablePirateIsland.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// for MVP2
class UpdatablePirateIsland: EngineObject, Updatable {

    var data: VisualAudioData? {
        get {
            return VisualAudioData(
                contextualData: ContextualData.image(image: Resources.Misc.pirateNode),
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
