//
//  GenericTurnSystem.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystem {
    var gameState: GenericGameState { get }
    func process(action: PlayerAction, for player: GenericPlayer) throws
    func roll(for player: GenericPlayer) throws -> Int
    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws
    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws
    func buy(item: ItemType, quantity: Int, by player: GenericPlayer) throws
    func sell(item: ItemType, quantity: Int, by player: GenericPlayer) throws
    func watchMasterUpdate(gameState: GenericGameState)
    func watchTurnFinished(playerActions: [(GenericPlayer, [PlayerAction])])
    func endTurn()
    func endTurnCallback(action: @escaping () -> Void)
    func subscribeToState(with callback: @escaping (TurnSystem.State) -> Void)
    func startGame()
}
