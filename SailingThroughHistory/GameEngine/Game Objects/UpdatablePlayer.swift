//
//  UpdatablePlayer.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatablePlayer: Updatable {

    var data: VisualAudioData? {
        get {
            let data = VisualAudioData(
                contextualData: ContextualData.animated(images: Resources.Ships.british,
                    startingFrame: 0, loopDuration: Double.infinity),
                sound: SoundData.none)
            return data
        }
    }

    func update() -> Bool {
        return false
    }
    
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }

}
