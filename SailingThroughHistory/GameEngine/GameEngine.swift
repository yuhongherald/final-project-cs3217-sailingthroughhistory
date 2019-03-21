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
    private var isPlayerTurn: Bool = false
    private var gameLogic: GenericGameLogic

    // TODO: extract interface into protocol
    // something for me to draw on
    private let interface: Interface
    private var emotionEngine: GenericTurnBasedGame
    private let wrapper: GenericAsyncWrap
    private let diceFactory: DiceFactory
    private let stopWatch: Stopwatch = Stopwatch(smallestInterval:
        GameConstants.smallestEngineTick)

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
            self.interface.currentTurnOwner = nil
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
            guard let updatables = updateGameState() else {
                continue
            }
            updateInterface(updatables: updatables)
        }
    }

    private func updateGameState() -> [UpdatableWrapper]? { // change
        let newTime = stopWatch.getTimestamp()
        let timeDifference = (newTime - emotionEngine.currentGameTime)
        guard let event = emotionEngine.updateGameState(deltaTime: timeDifference) else {
            return nil
        }
        switch event.eventType {
        case .actionRequired(playerIdentifier: let identifier):
            stopWatch.stop()
            interface.currentTurnOwner = identifier
            break
        default: break
        }
        return nil
    }

    private func updateInterface(updatables: AnyIterator<UpdatableWrapper>) {
        for updatable in updatables {
        //interface.add(object: <#T##GameObject#>)
        //interface.disposeBag.insert(<#T##disposable: Disposable##Disposable#>)
        }
    }
}
