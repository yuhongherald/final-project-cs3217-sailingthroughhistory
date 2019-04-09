//
//  GenericGameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericGameState: Codable {
    var gameTime: GameVariable<GameTime> { get set }
    var gameObjects: [GameObject] { get }
    var map: Map { get }
    var itemParameters: [ItemParameter] { get set }

    func getPlayers() -> [GenericPlayer]
    func startNextTurn(speedMultiplier: Double)
    func getNextPlayer() -> GenericPlayer?
    func endGame()
}
