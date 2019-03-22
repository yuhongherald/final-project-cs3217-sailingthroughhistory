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

    private let interface: Interface
    private let wrapper: GenericAsyncWrap
    private let diceFactory: DiceFactory
    private let stopWatch: Stopwatch = Stopwatch(smallestInterval:
        EngineConstants.smallestEngineTick)

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
        self.interface = interface
        self.emotionEngine = emotionEngine
        self.wrapper = asyncWrapper
        self.diceFactory = diceFactory
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
        loop()
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
        stopWatch.stop()
        isRunning = false
    }

    // invalidate the cache if there is a change that makes predicted outcomes invalid
    func resume(invalidateCache: Bool) {
        stopWatch.start()
        emotionEngine.invalidateCache()
        loop()
    }

    private func loop() {
        wrapper.async {
            while self.isValid || self.isRunning {
                let (newEvent, updatables) = self.updateGameState()
                self.updateObjects(updatables: updatables)
                self.updateInterface(newEvent: newEvent)
            }
            if !self.isValid {
                self.endGame?()
            }
        }
    }

    private func updateGameState() -> (GenericGameEvent?, AnyIterator<Updatable>) {
        guard !emotionEngine.hasCachedUpdates() else {
            return emotionEngine.finishCachedUpdates()
        }
        let newTime = stopWatch.getTimestamp()
        let timeDifference = (newTime - emotionEngine.currentGameTime)
        return emotionEngine.updateGameState(deltaTime: timeDifference)
        
    }

    private func updateObjects(updatables: AnyIterator<Updatable>) {
        for updatable in updatables {
            switch updatable.
        }
    }

    private func updateInterface(newEvent: GenericGameEvent?) {
        guard let event = newEvent else {
            return
        }
        switch event.eventType {
        case .actionRequired(playerIdentifier: let identifier):
            stopWatch.stop()
            /// TODO: Set these
            let timeLimit: TimeInterval? = nil
            let timeOutCallback: () -> Void = { }
            interface.playerTurnStart(player: identifier, timeLimit: timeLimit, timeOutCallback: timeOutCallback)
            break
        default: break
        }
        guard let event = newEvent else {
            return
        }
        switch event.eventType {
        case .actionRequired(playerIdentifier: let player):
            interface.startPlayerTurn(player: player)
        case .informative(initiater: let initiator):
            interface.showNotification(message: event.message)
        }
    }
}
