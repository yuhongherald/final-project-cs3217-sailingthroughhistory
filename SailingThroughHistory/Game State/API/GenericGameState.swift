//
//  GenericGameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericGameState {
    func loadLevel(level: Level)
    func startNextTurn(speedMultiplier: Double)
    func getNextPlayer() -> Player?
    func endGame()
}
