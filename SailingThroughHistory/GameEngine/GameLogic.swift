//
//  GameBoard.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: GenericGameLogic {
    private let gameState: GenericGameState
    private var weathers: Set<UpdatableWeather> = Set<UpdatableWeather>()
    private var ports: Set<UpdatablePort> = Set<UpdatablePort>()
    private var players: Set<UpdatablePlayer> = Set<UpdatablePlayer>()
    private var npcs: Set<UpdatableNPC> = Set<UpdatableNPC>()
    private var pirates: Set<UpdatablePirate> = Set<UpdatablePirate>()
    private var time: Set<UpdatableTime> = Set<UpdatableTime>()
    private var playerTurn: Set<UpdatablePlayerTurn> = Set<UpdatablePlayerTurn>()
    private var pirateIsland: Set<UpdatablePirateIsland> = Set<UpdatablePirateIsland>()

    init(gameState: GenericGameState) {
        self.gameState = gameState
    }

    func getUpdatablesFor(deltaTime: Double) -> AnyIterator<Updatable> {
        // player turn first
        // weather next
        // pirate, npc and player
        // pirate island here probably
        // port next
        // time last
        return AnyIterator {
            
        }
    }

    func getDrawables() -> AnyIterator<GameObject> {
        return AnyIterator {}
    }
}
