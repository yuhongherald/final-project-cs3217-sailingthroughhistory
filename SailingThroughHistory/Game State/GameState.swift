//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameState: GenericGameState {
    private var players = [GameVariable<Player>]()
    private var level: GameVariable<Level>?
    private var speedMultiplier = 1.0
    
    private var playerTurnOrder = [Player]()
    
    public func loadLevel(level: Level) {
    }
    
    public func getNextPlayer() -> Player? {
        return playerTurnOrder.removeFirst()
    }
    
    public func startNextTurn(speedMultiplier: Double) {
        self.speedMultiplier = speedMultiplier
    }
    
    public func endGame() {
    }
    

}
