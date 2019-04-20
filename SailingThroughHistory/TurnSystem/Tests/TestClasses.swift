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
        var nextId = port.identifier + 1
        let node = NodeStub(name: "node", identifier: nextId)
        map.addNode(port)
        map.addNode(node)
        map.add(path: Path(from: port, to: node))
        map.add(path: Path(from: node, to: port))
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
    static func createTestState(numPlayers: Int) -> TurnSystemState {
        return TurnSystemState(
            gameState: createGame(numPlayers: numPlayers), joinOnTurn: 0)
    }
    static func createNetworkInfo() -> NetworkInfo {
        return NetworkInfo("testDevice", false)
    }
    static func createTestSystemNetwork(numPlayers: Int) -> TurnSystemNetwork {
        return TurnSystemNetwork(roomConnection: TestRoomConnection(),
                                 playerActionAdapterFactory:
                                    PlayerActionAdapterFactory(),
                                 networkInfo: createNetworkInfo(),
                                 turnSystemState: createTestState(numPlayers: numPlayers))
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
    static func createInputController(timer: Double) -> PlayerInputController {
        let network = createTestSystemNetwork(numPlayers: 1)
        let controller = PlayerInputController(
            network: network,
            data: network.data)
        controller.duration = timer
        return controller
    }
    static func createTestEvent(identifier: Int) -> TurnSystemEvent {
        let event = TurnSystemEvent(triggers: [], conditions: [], actions: [],
                        parsable: { "Test event" }, displayName: "Test event")
        event.identifier = identifier
        return event
    }
    static func createPresetEvent(identifier: Int) -> PresetEvent {
        let result = TaxChangeEvent(gameState: TestClasses.createGame(numPlayers: 1),
                       genericOperator: AddOperator<Int>(), modifier: 1)
        result.identifier = identifier
        return result
    }
}
