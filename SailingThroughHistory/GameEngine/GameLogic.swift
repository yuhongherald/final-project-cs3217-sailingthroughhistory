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
    private var totalTime: Double = 0
    private var weeks: Double = 0

    init(gameState: GenericGameState) {
        self.gameState = gameState
        // add player turns
        objects.insert(UpdatablePlayerTurn(gameState: gameState))
        for player in gameState.getPlayers() {
            objects.insert(UpdatablePlayer(location: player.getLocation()))
            objects.insert(UpdatableTime(gameState: gameState))
        }
    }

    private func getUpdatablesFor(deltaTime: Double) -> [Updatable] {
        totalTime += deltaTime
        weeks = deltaTime / EngineConstants.weeksToSeconds
        // player turn first
        // weather next
        // pirate, npc and player
        // pirate island here probably
        // port next
        // time last
        var result: [Updatable] = []
        let updatables = Array(objects).filter{ $0 is Updatable } as? [Updatable] ?? [Updatable]()
        result.append(contentsOf: updatables.filter { $0 is UpdatablePlayerTurn })
        result.append(contentsOf: updatables.filter { $0 is UpdatableWeather })
        result.append(contentsOf: updatables.filter { $0 is UpdatablePirate })
        result.append(contentsOf: updatables.filter { $0 is UpdatableNPC })
        result.append(contentsOf: updatables.filter { $0 is UpdatablePlayer })
        result.append(contentsOf: updatables.filter { $0 is UpdatablePort })
        result.append(contentsOf: updatables.filter { $0 is UpdatableTime })

        return result
    }

    func updateForTime(deltaTime: Double) -> GenericGameEvent? {
        setCache(updatables: getUpdatablesFor(deltaTime: deltaTime))
        return processCachedUpdates()
    }

    func processCachedUpdates() -> GenericGameEvent? {
        while let updatable = updatableCache?.next() {
            _ = updatable.update(weeks: weeks)
            guard let object = updatable as? GameObject else {
                // should not happen
                continue
            }
            switch updatable.status {
            case .add:
                addedObjects.insert(object)
            case .update:
                updatedObjects.insert(object)
            case .delete:
                removedObjects.insert(object)
            default:
                break
            }
            guard var event = updatable.checkForEvent() else {
                continue
            }
            event.timestamp = totalTime
            return event
        }
        return nil
    }
    
    func hasCachedUpdates() -> Bool {
        guard let cache = updatableCache else {
            return false
        }
        return cache.contains(where: { $0 != nil })
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
