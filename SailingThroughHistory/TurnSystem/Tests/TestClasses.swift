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
    func getPresetEventsTest() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 0)
        guard let events = turnSystem.eventPresets?.getEvents() else {
            //XCTFail("Turn system initialized without event presets")
            return
        }
        let otherEvents = turnSystem.getPresetEvents()
        //XCTAssertEqual(events.map { $0.displayName }, otherEvents.map { $0.displayName }, "Events not same!")
    }

    func startGameTest() {
        let turnSystem0 = TestClasses.createTestSystem(numPlayers: 0)
        let turnSystem1 = TestClasses.createTestSystem(numPlayers: 1)
        let turnSystem2 = TestClasses.createTestSystem(numPlayers: 2)

        /*
        turnSystem0.startGame()
        XCTAssertEqual(turnSystem0.network.state, TurnSystemNetwork.State.waitForTurnFinish, "Wrong state for 0 players")
        turnSystem1.startGame()
        XCTAssertEqual(turnSystem1.network.state,
                       TurnSystemNetwork.State.waitPlayerInput(
                       from: turnSystem1.gameState.getPlayers()[0]),
                       "Wrong state for 1 player")
         turnSystem2.startGame()
         XCTAssertEqual(turnSystem2.network.state,
         TurnSystemNetwork.State.waitPlayerInput(
         from: turnSystem2.gameState.getPlayers()[0]),
         "Wrong state for 2 players")
         */
    }

    // to represent all the actions
    func rollTest() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 1)
        turnSystem.startGame()
        do {
            _ = try turnSystem.roll(for: turnSystem.gameState.getPlayers()[0])
        } catch {
            //XCTFail("Failed to roll the dice, wrong state")
        }
    }

    func subscribeToStateTest() {
        let result = GameVariable<Bool>(value: false)
        let turnSystem = TestClasses.createTestSystem(numPlayers: 1)
        turnSystem.subscribeToState {_ in
            result.value = true
        }
        turnSystem.startGame()
        //XCTAssertTrue(result.value, "Not notified on subscription!")
    }

    func endTurnTest() {
        let turnSystem = TestClasses.createTestSystem(numPlayers: 1)
        turnSystem.startGame()
        turnSystem.endTurn()
        //XCTAssertEqual(turnSystem.state, TurnSystemNetwork.State.waitForTurnFinish,
        //               "Should be waiting for turn to finish!")
    }
}
