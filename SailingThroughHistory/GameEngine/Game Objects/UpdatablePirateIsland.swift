//
//  UpdatablePirateIsland.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// for MVP2
class UpdatablePirateIsland: GameObject, Updatable {
    var status: UpdatableStatus = .add

    func update() -> Bool {
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
