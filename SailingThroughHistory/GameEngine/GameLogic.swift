//
//  GameBoard.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: GenericGameLogic {

    var gameState: GenericGameState?

    func getUpdatables(deltaTime: Double) -> AnyIterator<Updatable> {
        // player turn first
        // time last
        return AnyIterator {
            return nil
        }
    }

    func getNewGameObjects() -> AnyIterator<GameObject> {
        return AnyIterator {
            return nil
        }
    }

    func getUpdatedGameObjects() -> AnyIterator<GameObject> {
        return AnyIterator {
            return nil
        }
    }

    func getDeletedGameObjects() -> AnyIterator<GameObject> {
        return AnyIterator {
            return nil
        }
    }
}
