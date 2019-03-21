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
        // weather next
        // pirate, npc and player
        // pirate island here probably
        // port next
        // time last
        return AnyIterator {
            return nil
        }
    }

    func getNewGameObjects() -> AnyIterator<Drawable> {
        return AnyIterator {
            return nil
        }
    }

    func getUpdatedGameObjects() -> AnyIterator<Drawable> {
        return AnyIterator {
            return nil
        }
    }

    func getDeletedGameObjects() -> AnyIterator<Drawable> {
        return AnyIterator {
            return nil
        }
    }
}
