//
//  GameEngine.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class GameEngine {
    private var hasStarted: Bool = false
    private var isRunning: Bool = false
    private var isValid: Bool = true

    private var emotionEngine: GenericTurnBasedGame
    private var endGame: (() -> Void)?

    private let wrapper: GenericAsyncWrap
    private let diceFactory: DiceFactory
    private let stopWatch: Stopwatch = Stopwatch(smallestInterval:
        EngineConstants.smallestEngineTick)
    private let gameInterface: GameInterface

    var gameSpeed: Double {
        get {
            return emotionEngine.externalGameSpeed
        }
        set {
            wrapper.async {
                self.emotionEngine.externalGameSpeed = newValue
            }
        }
    }

    init(interface: Interface, emotionEngine: GenericTurnBasedGame,
         asyncWrapper: GenericAsyncWrap, diceFactory: DiceFactory) {
        self.gameInterface = GameInterface(interface: interface)
        self.emotionEngine = emotionEngine
        self.wrapper = asyncWrapper
        self.diceFactory = diceFactory
        gameInterface.registerCallback(for: self)
    }

    func start(endGame: (() -> Void)?) {
        if hasStarted || !isValid {
            return
        }
        hasStarted = true
        isRunning = true
        stopWatch.resetTimer()
        stopWatch.start()
        self.endGame = endGame
        wrapper.async {
            self.loop()
        }
    }

    func roll(lower: Int, upper: Int) -> Int {
        return diceFactory.createDice(lower: lower, upper: upper).roll()
    }

    func asyncPause() {
        wrapper.async {
            self.pause()
        }
    }

    private func pause() {
        if !isRunning || !hasStarted || !isValid {
            return
        }
        stopWatch.stop()
        isRunning = false
    }

    // invalidate the cache if there is a change that makes predicted outcomes invalid
    func asyncResume(invalidateCache: Bool) {
        wrapper.async {
            self.resume(invalidateCache: invalidateCache)
        }
    }

    private func resume(invalidateCache: Bool) {
        if isRunning || !hasStarted || !isValid {
            return
        }
        stopWatch.start()
        if invalidateCache {
            emotionEngine.invalidateCache()
        }
        isRunning = true
        loop()
    }

    private func loop() {
        while isValid || isRunning {
            let newEvent = updateGameState()
            let drawables = emotionEngine.getDrawables()
        }
        if !isValid {
            endGame?()
        }
    }

    private func updateGameState() -> GenericGameEvent? {
        guard !emotionEngine.hasCachedUpdates() else {
            return emotionEngine.finishCachedUpdates()
        }
        let newTime = stopWatch.getTimestamp()
        let timeDifference = (newTime - emotionEngine.currentGameTime)
        return emotionEngine.updateGameState(deltaTime: timeDifference)
    }

    private func updateInterface(newEvent: GenericGameEvent?) {
        guard let event = newEvent else {
            return
        }
        switch event.eventType {
        case .actionRequired(playerIdentifier: let player):
            pause()
            gameInterface.startPlayerTurn(player: player) {
                self.asyncResume(invalidateCache: true)
            }
        case .informative(initiater: let initiator):
            guard let message = event.message else {
                return
            }
            pause()
            gameInterface.showNotification(message: message)
        }
    }
}
