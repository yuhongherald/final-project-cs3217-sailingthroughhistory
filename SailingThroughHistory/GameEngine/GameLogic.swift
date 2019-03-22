//
//  GameBoard.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: GenericGameLogic {
    internal func addToCache(updatables: [Updatable]) {
        updatableCache = AnyIterator {
            for updatable in updatables {
                return updatable
            }
        }
    }
    
    private var updatableCache: AnyIterator<Updatable>?
    func updateForTime(deltaTime: Double) -> GenericGameEvent? {
        // TODO: Add update logic
        addToCache(updatables: [])
    }

    func processCachedUpdates() -> GenericGameEvent? {
        while let updatable = updatableCache?.next() {
            _ = updatable.update()
            guard let event = updatable.checkForEvent() else {
                continue
            }
            return event
        }
        return nil
    }

    func hasCachedUpdates() -> Bool {
        return updatableCache != nil
    }
    func invalidateCache() {
        updatableCache = nil
    }
    
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

    func getUpdatablesFor(deltaTime: Double) -> [Updatable] {
        // player turn first
        // weather next
        // pirate, npc and player
        // pirate island here probably
        // port next
        // time last
        return []
    }

    func getAddedDrawables() -> [GameObject] {
        <#code#>
    }
    
    func getUpdatedDrawables() -> [GameObject] {
        <#code#>
    }
    
    func getDeletedDrawables() -> [GameObject] {
        <#code#>
    }
    
    func approvedDeletedDrawables() {
        <#code#>
    }
}
