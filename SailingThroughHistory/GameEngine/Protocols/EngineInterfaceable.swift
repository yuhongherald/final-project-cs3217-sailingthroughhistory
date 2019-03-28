//
//  EngineInterfaceable.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol EngineInterfaceable {
    func addObjects(gameObjects: Set<GameObject>)
    func updateObjects(gameObjects: Set<GameObject>)
    func removeObjects(gameObjects: Set<GameObject>)
    func finishObjectEdit(deltaTime: Double)
    func startPlayerTurn(player: GenericPlayer, callback: @escaping () -> Void)
    func showNotification(message: VisualAudioData)
    func registerCallback(for gameEngine: GameEngine)
}
