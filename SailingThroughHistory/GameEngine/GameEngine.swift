//
//  GameEngine.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameEngine {
    private var underlyingGameSpeed: Double = 1
    private var group: DispatchGroup = DispatchGroup()
    private var isRunning: Bool = false
    private var isValid: Bool = true

    private var gameState: GameState
    // something for me to draw on
    private var interface: Interface
    private var wrapper: AsyncWrap
    // an exit point for the game
    private var endGame: () -> Void

    var gameSpeed: Double {
        get {
            return underlyingGameSpeed
        }
        set {
            wrapper.async {
                self.underlyingGameSpeed = newValue
            }
        }
    }

    init(gameState: GameState, interface: Interface,
         asyncWrapper: AsyncWrap, endGame: @escaping () -> Void) {
        self.gameState = gameState
        self.wrapper = asyncWrapper
        self.endGame = endGame
    }
    
    func start() {
        if isRunning || !isValid {
            return
        }
        isRunning = true
        repeatLoop()
    }

    private func repeatLoop() {
        wrapper.async {
            guard self.isValid else {
                return
            }
            self.loop()
        }
    }

    private func loop() {
        // TODO: Add game logic here
        repeatLoop()
    }

}
