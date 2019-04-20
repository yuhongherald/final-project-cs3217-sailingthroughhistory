//
//  TestClasses.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TestClasses {
    static func createGame() -> GenericGameState {
        return GameState(baseYear: 1800,
                  level: GameParameter(map: Map(map: "test map", bounds: nil), teams: []),
                  players: [])
    }
    static func createTurnSystem() -> GenericTurnSystem {
        return TestTurnSystem()
    }
    static func createEventPresets() -> EventPresets {
        let testSystem = createTurnSystem()
        return EventPresets(gameState: testSystem.gameState, turnSystem: testSystem)
    }
    static func createTestSystemNetwork() -> TurnSystemNetwork {
        return TurnSystemNetwork(roomConnection: LocalRoomConnection(""),
                                 playerActionAdapterFactory: GenericPlayerActionAdapterFactory,
                                 networkInfo: NetworkInfo,
                                 turnSystemState: GenericTurnSystemState)
    }
}
