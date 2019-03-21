//
//  UpdatablePirate.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatablePirate: Updatable {
    var status: DrawableStatus = DrawableStatus.add
    var gameObjectBox: GameObjectBox
    init(gameObject: GameObject) {
        self.gameObjectBox = GameObjectBox(gameObject: gameObject)
    }
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
    
    func update() -> Bool {
        return false
    }
    
}
