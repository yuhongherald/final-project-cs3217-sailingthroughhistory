//
//  GenericTurnSystem.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystem {
    var gameState: GenericGameState { get }
    var eventPresets: EventPresets? { get set }
    var messages: [GameMessage] { get set }
    func getPresetEvents() -> [PresetEvent]
    func roll(for player: GenericPlayer) throws -> (Int, [Int])
    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws
    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws
    func buy(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws
    func sell(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws
    func toggle(eventId: Int, enabled: Bool, by player: GenericPlayer) throws
    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage?
    func watchMasterUpdate(gameState: GenericGameState)
    func endTurn()
    func subscribeToState(with callback: @escaping (TurnSystem.State) -> Void)
    func startGame()
    func acknoledgeTurnStart()
}
