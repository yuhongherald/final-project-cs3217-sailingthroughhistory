//
//  UpdatablePlayer.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UpdatablePlayer: GameObject, Updatable {
    var status: UpdatableStatus = .add

    init(gameState: GenericGameState) {
        super.init(image: Resources.Ships.british[0], frame: Rect())
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func update(weeks: Double) -> Bool {
        return false
    }
    
    func checkForEvent() -> GenericGameEvent? {
        return nil
    }

}
