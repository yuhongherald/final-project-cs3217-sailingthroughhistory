//
//  UpdatableTime.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatableTime: GameObject, Updatable {
    var status: UpdatableStatus = .add
    private var gameState: GenericGameState

    init(gameState: GenericGameState) {
        self.gameState = gameState
        super.init()
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    func update(weeks: Double) -> Bool {
        gameState.gameTime.addWeeks(weeks)
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        return nil
    }
}
