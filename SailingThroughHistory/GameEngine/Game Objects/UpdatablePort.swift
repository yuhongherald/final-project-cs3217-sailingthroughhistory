//
//  UpdatablePort.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatablePort: EngineObject, Updatable {
    var data: VisualAudioData? {
        get {
            let data = VisualAudioData(
                contextualData: ContextualData.image(image: Resources.Misc.portNode),
                sound: GameSound.none)
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
