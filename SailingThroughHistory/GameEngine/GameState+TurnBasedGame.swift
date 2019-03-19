//
//  GameState+TurnBasedGame.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension GameState: TurnBasedGame {
    var playerTurn: PlayerTurn? {
        get {
            return nil
        }
        set {
        }
    }
    
    var currentGameTime: Double {
        return 0
    }
    
    var largestTimeStep: Double {
        get {
            return 0
        }
        set {
        }
    }
    
    var forecastDuration: Double {
        get {
            return 0
        }
        set {
        }
    }
    
    func updateGameState(deltaTime: Double) -> Event? {
        return nil
    }
    
}
