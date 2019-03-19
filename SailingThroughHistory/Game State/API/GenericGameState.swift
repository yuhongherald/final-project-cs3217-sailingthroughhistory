//
//  GenericGameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericGameState {
    func subscribe(interface: Interface)
    func loadLevel(level: GenericLevel)
    func startNextTurn(speedMultiplier: Double)
    func getNextPlayer() -> Player?
    func endGame()
}
