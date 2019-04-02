//
//  GenericGameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericGameState: Codable {
    var gameTime: GameTime { get set }
    var itemParameters: [ItemParameter] { get set }

    init(baseYear: Int)
    func loadLevel(level: GenericLevel)
    func getPlayers() -> [GenericPlayer]
    func startNextTurn(speedMultiplier: Double)
    func getNextPlayer() -> GenericPlayer?
    func endGame()
}
