//
//  TestClasses.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TestClasses {
    static let baseYear: Int = 1800
    static let team: String = "British"
    static let buyPrice: Int = 100
    static let sellPrice: Int = 100
    static func createMap() -> Map {
        let map = Map(map: "test map", bounds: nil)
        let port = PortStub(buyValueOfAllItems: buyPrice, sellValueOfAllItems: sellPrice)
        map.addNode(port)
        return map
    }
    static func createLevel() -> GenericLevel {
        return GameParameter(map: createMap(), teams: [team])
    }
    static func createGame(numPlayers: Int) -> GenericGameState {
        return GameState(baseYear: baseYear,
                  level: createLevel(),
                  players: createPlayers(numPlayers: numPlayers))
    }
    static func createTurnSystem() -> GenericTurnSystem {
        return TestTurnSystem()
    }
    static func createEventPresets() -> EventPresets {
        let testSystem = createTurnSystem()
        return EventPresets(gameState: testSystem.gameState, turnSystem: testSystem)
    }
    static func createTestSystemNetwork(numPlayers: Int) -> TurnSystemNetwork {
        return TurnSystemNetwork(roomConnection: TestRoomConnection(),
                                 playerActionAdapterFactory:
                                    PlayerActionAdapterFactory(),
                                 networkInfo: NetworkInfo("testDevice", false),
                                 turnSystemState: TurnSystemState(
                                    gameState: createGame(numPlayers: numPlayers), joinOnTurn: 0))
    }
    static func createTestSystem(numPlayers: Int) -> TurnSystem {
        return TurnSystem(network: createTestSystemNetwork(numPlayers: numPlayers), playerInputControllerFactory: PlayerInputControllerFactory())
    }
    static func createPlayers(numPlayers: Int) -> [RoomMember] {
        var result: [RoomMember] = []
        for index in 0..<numPlayers {
            result.append(RoomMember(identifier: String(index), playerName: String(index),
                                     teamName: team, deviceId: String(index)))
        }
        return result
    }
}

class TestBed {
}
