//
//  GameEngine.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameEngine {
    private var underlyingGameSpeed: Double = 1
    private var isRunning: Bool = false
    private var isValid: Bool = true

    // TODO: extract interface into protocol
    // something for me to draw on
    private let interface: Interface
    private let gameLogic: TurnBasedGame
    private let wrapper: AsyncWrap

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

    init(interface: Interface, gameLogic: TurnBasedGame, asyncWrapper: AsyncWrap) {
        self.interface = interface
        self.gameLogic = gameLogic
        self.wrapper = asyncWrapper
    }

    func start(endGame: @escaping () -> Void) {
        if isRunning || !isValid {
            return
        }
        isRunning = true
        wrapper.resetTimer()
        repeatLoop(endGame)
    }

    private func repeatLoop(_ endGame: @escaping () -> Void) {
        wrapper.async {
            guard self.isValid else {
                endGame()
                return
            }
            self.loop(endGame)
        }
    }

    private func loop(_ endGame: @escaping () -> Void) {
        updateGameState()
        updateInterface()
        repeatLoop(endGame)
    }

    private func updateGameState() {
        let newTime = wrapper.getTimestamp()
        let timeDifference = (newTime - gameLogic.currentGameTime) * gameSpeed
        gameLogic.updateGameState(deltaTime: timeDifference)
    }

    private func updateInterface() {
        // TODO: Write protocol for wrapping interface
    }
}
