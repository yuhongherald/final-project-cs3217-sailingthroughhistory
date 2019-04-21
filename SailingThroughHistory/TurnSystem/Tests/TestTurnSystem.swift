//
//  TestTurnSystem.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A stub of TurnSystem, to be used for testing.
 */
class TestTurnSystem: GenericTurnSystem {
    var gameState: GenericGameState = TestClasses.createGame(numPlayers: 1)
    var eventPresets: EventPresets?
    var messages: [GameMessage] = []
    func getPresetEvents() -> [PresetEvent] {
        fatalError("This should not be called")
    }
    
    func roll(for player: GenericPlayer) throws -> (Int, [Int]) {
        fatalError("This should not be called")
    }
    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws {
        fatalError("This should not be called")
    }
    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws {
        fatalError("This should not be called")
    }
    func buy(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        fatalError("This should not be called")
    }
    func sell(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        fatalError("This should not be called")
    }
    func toggle(eventId: Int, enabled: Bool, by player: GenericPlayer) throws {
        fatalError("This should not be called")
    }
    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage? {        fatalError("This should not be called")
    }
    
    func subscribeToState(with callback: @escaping (TurnSystemNetwork.State) -> Void) {
        fatalError("This should not be called")
    }
    func startGame() {
        fatalError("This should not be called")
    }
    func endTurn() {
        fatalError("This should not be called")
    }
    func acknowledgeTurnStart() {
        fatalError("This should not be called")
    }

}
