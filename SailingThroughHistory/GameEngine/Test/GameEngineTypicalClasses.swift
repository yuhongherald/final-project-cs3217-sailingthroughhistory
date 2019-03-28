//
//  GameEngineTypicalClasses.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameEngineTypicalClasses {
    static func getTypicalGameState() -> GenericGameState {
        // use testgamestate here
        return GameState(baseYear: 1800)
    }
    static func getTypicalInterface() -> TestInterface {
        return TestInterface()
    }
    static func getTypicalGameEngine(with gameState: GenericGameState,
                                     and interface: EngineInterfaceable) -> GameEngine {
        let gameLogic = GameLogic(gameState: gameState)
        let emotionEngine = EmotionEngine(gameLogic: gameLogic)
        let asyncWrapper = GameAsyncWrap()
        let diceFactory = DiceFactory(randomizer: UniformRandom())
        let gameEngine = GameEngine(interface: interface,
                                emotionEngine: emotionEngine,
                                asyncWrapper: asyncWrapper,
                                diceFactory: diceFactory)
        return gameEngine
    }
}
