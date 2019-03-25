//
//  GameBoard.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameLogic: GenericGameLogic {
    var addedObjects: Set<GameObject> = Set<GameObject>()
    var updatedObjects: Set<GameObject> = Set<GameObject>()
    var removedObjects: Set<GameObject> = Set<GameObject>()

    private let gameState: GenericGameState
    /*
    private var weathers: Set<UpdatableWeather> = Set<UpdatableWeather>()
    private var ports: Set<UpdatablePort> = Set<UpdatablePort>()
    private var players: Set<UpdatablePlayer> = Set<UpdatablePlayer>()
    private var npcs: Set<UpdatableNPC> = Set<UpdatableNPC>()
    private var pirates: Set<UpdatablePirate> = Set<UpdatablePirate>()
    private var time: Set<UpdatableTime> = Set<UpdatableTime>()
    private var playerTurn: Set<UpdatablePlayerTurn> = Set<UpdatablePlayerTurn>()
    private var pirateIsland: Set<UpdatablePirateIsland> = Set<UpdatablePirateIsland>()
 */
    private var objects: Set<AnyHashable> = Set<AnyHashable>()
    private var updatableCache: AnyIterator<Updatable>?
    private var weeks: Double = 0

    init(gameState: GenericGameState) {
        self.gameState = gameState
        // add player turns
    }

    private func getUpdatablesFor(deltaTime: Double) -> [Updatable] {
        weeks = deltaTime / EngineConstants.weeksToSeconds
        // player turn first
        // weather next
        // pirate, npc and player
        // pirate island here probably
        // port next
        // time last
        var result: [Updatable] = []
        //result.append(objects.filter{ $0.base })
        return result
    }

    func updateForTime(deltaTime: Double) -> GenericGameEvent? {
        setCache(updatables: getUpdatablesFor(deltaTime: deltaTime))
        return processCachedUpdates()
    }
    
    func processCachedUpdates() -> GenericGameEvent? {
        while let updatable = updatableCache?.next() {
            _ = updatable.update(weeks: weeks)
            guard let event = updatable.checkForEvent() else {
                continue
            }
            return event
        }
        return nil
    }
    
    func hasCachedUpdates() -> Bool {
        guard let cache = updatableCache else {
            return false
        }
        //return !cache.isEmpty
        return false
    }
    func invalidateCache() {
        updatableCache = nil
    }

    func approveChanges() {
        addedObjects.removeAll()
        updatedObjects.removeAll()
        removedObjects.removeAll()
    }

    private func setCache(updatables: [Updatable]) {
        updatableCache = AnyIterator {
            for updatable in updatables {
                return updatable
            }
            return nil
        }
    }
}
