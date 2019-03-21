//
//  GameEngine.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class GameEngine {
    private var isRunning: Bool = false
    private var isValid: Bool = true
    private var isPlayerTurn: Bool = false
    private var gameLogic: GenericGameLogic

    // something for me to draw on
    private let interface: Interface
    private var emotionEngine: GenericTurnBasedGame
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
         gameLogic: GenericGameLogic,
         asyncWrapper: GenericAsyncWrap, diceFactory: DiceFactory) {
        self.interface = interface
        self.emotionEngine = emotionEngine
        self.wrapper = asyncWrapper
        self.diceFactory = diceFactory
        self.gameLogic = gameLogic
    }

    func start(endGame: @escaping () -> Void) {
        if isRunning || !isValid {
            return
        }
        isRunning = true
        stopWatch.resetTimer()
        stopWatch.start()
        repeatLoop(endGame)
    }

    func roll(lower: Int, upper: Int) -> Int {
        return diceFactory.createDice(lower: lower, upper: upper).roll()
    }

    /// invalidates the event cache in the emotion engine
    func endTurn() {
        wrapper.async {
            self.stopWatch.start()
            self.isPlayerTurn = false
            self.interface.endPlayerTurn()
            self.interface.broadcastInterfaceChanges(withDuration: 0)
            self.emotionEngine.invalidateCache()
        }
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
        while isValid {
            let newEvent = updateGameState()
            updateInterface(newEvent: newEvent)
        }
    }

    private func updateGameState() -> GenericGameEvent? { // change
        guard !emotionEngine.hasCachedUpdates() else {
            return emotionEngine.finishCachedUpdates()
        }
        let newTime = stopWatch.getTimestamp()
        let timeDifference = (newTime - emotionEngine.currentGameTime)
        let updatables = gameLogic.getUpdatables(deltaTime: timeDifference)
        guard let event = emotionEngine.updateGameState(deltaTime: timeDifference) else {
            return nil
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
        return nil
    }

    private func updateInterface(newEvent: GenericGameEvent?) {
        for newObj in gameLogic.getNewGameObjects() {
            // interface.add(object: newObj)
        }
        for updatedObj in gameLogic.getUpdatedGameObjects() {
            // currrently updated directly, no further action required
        }
        for deletedObj in gameLogic.getDeletedGameObjects() {
            // TODO: Dispose?
            // interface.disposeBag.insert(deletedObj)
        }
        guard let event = newEvent else {
            return
        }
        // TODO: Draw message
    }
}
