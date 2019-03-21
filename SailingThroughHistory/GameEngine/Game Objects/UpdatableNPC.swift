//
//  UpdatableNPC.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableNPC: EngineObject, Updatable {
    
    var data: ContextualData {
        get {
            return
        }
    }
    
    func update() -> Bool {
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }

}
