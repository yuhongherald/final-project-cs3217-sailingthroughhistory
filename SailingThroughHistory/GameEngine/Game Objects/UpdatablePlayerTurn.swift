//
//  UpdatablePlayerTurn.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatablePlayerTurn: Updatable {

    var data: VisualAudioData? {
        get {
            return VisualAudioData(
                contextualData: ContextualData.message(message: "This is the player turn"),
                sound: SoundData.none)
        }
    }

    func update() -> Bool {
        return false
    }
    
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
