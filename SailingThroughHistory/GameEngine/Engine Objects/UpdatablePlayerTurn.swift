//
//  UpdatablePlayerTurn.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class UpdatablePlayerTurn: GameObject, Updatable {
    var status: UpdatableStatus = .add
    private let gameState: GenericGameState
    private let nextGameTime: GameTime
    private var nextTurn: Bool = false

    init(gameState: GenericGameState) {
        self.gameState = gameState
        nextGameTime = gameState.gameTime
        super.init()
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    func update(weeks: Double) -> Bool {
        // no graphical support yet
        return false
    }

    func checkForEvent() -> GenericGameEvent? {
        if !nextTurn {
            gameState.getNextPlayer()?.endTurn() // Remove hotfix
        }
        guard let nextPlayer = gameState.getNextPlayer() else {
            if !nextTurn {
                nextTurn = true
                return GameEvent(eventType: EventType.informative(initiater: "Player turn"), timestamp: 0, message: nil)
            }
            return nil
        }
        nextTurn = false
        return GameEvent(eventType: EventType.actionRequired(playerIdentifier: nextPlayer), timestamp: 0, message: nil)
    }
}
