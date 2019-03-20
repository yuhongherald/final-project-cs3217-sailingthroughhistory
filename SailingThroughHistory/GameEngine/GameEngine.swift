//
//  GameEngine.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameEngine {
    private var isRunning: Bool = false
    private var isValid: Bool = true

    // TODO: extract interface into protocol
    // something for me to draw on
    private let interface: Interface
    private var gameLogic: GenericTurnBasedGame
    private let wrapper: GenericAsyncWrap
    private let diceFactory: DiceFactory

    var gameSpeed: Double {
        get {
            return gameLogic.externalGameSpeed
        }
        set {
            wrapper.async {
                self.gameLogic.externalGameSpeed = newValue
            }
        }
    }

    init(interface: Interface, gameLogic: GenericTurnBasedGame,
         asyncWrapper: GenericAsyncWrap, diceFactory: DiceFactory) {
        self.interface = interface
        self.gameLogic = gameLogic
        self.wrapper = asyncWrapper
        self.diceFactory = diceFactory
    }

    func start(endGame: @escaping () -> Void) {
        if isRunning || !isValid {
            return
        }
        isRunning = true
        wrapper.resetTimer()
        repeatLoop(endGame)
    }

    func roll(lower: Int, upper: Int) -> Int {
        return diceFactory.createDice(lower: lower, upper: upper).roll()
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
        let timeDifference = (newTime - gameLogic.currentGameTime)
        wrapper.async {
            guard let event = self.gameLogic.updateGameState(deltaTime: timeDifference) else {
                return
            }
            // TODO: Add Player turn logic
        }
    }

    private func updateInterface() {
        wrapper.async {
            // TODO: Write protocol for wrapping interface
        }
    }
}
