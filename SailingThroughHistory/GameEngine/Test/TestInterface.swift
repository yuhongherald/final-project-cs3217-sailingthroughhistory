//
//  TestInterface.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TestInterface: EngineInterfaceable {
    var objects: [GameObject: Bool] = [GameObject: Bool]()
    var displayedMessage: VisualAudioData?
    var playerActionTime: Double = 1
    private var added: Set<GameObject> = Set<GameObject>()
    private var updated: Set<GameObject> = Set<GameObject>()
    private var removed: Set<GameObject> = Set<GameObject>()
    private var gameEngine: GameEngine?

    func addObjects(gameObjects: Set<GameObject>) {
        for object in gameObjects {
            added.insert(object)
        }
    }

    func updateObjects(gameObjects: Set<GameObject>) {
        for object in gameObjects {
            updated.insert(object)
        }
    }

    func removeObjects(gameObjects: Set<GameObject>) {
        for object in gameObjects {
            removed.insert(object)
        }
    }

    func finishObjectEdit(deltaTime: Double) {
        for object in added {
            objects[object] = true
        }
        for object in updated {
            objects[object] = false
        }
        for object in removed {
            objects[object] = nil
            //objects.removeValue(forKey: object)
        }
        added.removeAll()
        updated.removeAll()
        removed.removeAll()
        for (object, animated) in objects where animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + deltaTime) {
                self.objects[object] = false;
            }
        }
    }
    
    func startPlayerTurn(player: GenericPlayer, callback: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + playerActionTime) {
            callback()
        }
    }
    
    func showNotification(message: VisualAudioData) {
        displayedMessage = message
    }

    func registerCallback(for gameEngine: GameEngine) {
        self.gameEngine = gameEngine
    }

    // for testing
    func pause() {
        gameEngine?.asyncPause()
    }

    func resume() {
        gameEngine?.asyncResume(invalidateCache: false)
    }

    func endPlayerTurn() {
        gameEngine?.asyncResume(invalidateCache: true)
    }
}
