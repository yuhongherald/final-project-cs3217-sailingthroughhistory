//
//  GenericPlayer.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines the behaviors that a Player needs to support. These behaviors are mostly
/// player actions, such as buying/selling items, moving their ship, or interactions
/// with the game, such as being chased by pirates.
import Foundation

protocol GenericPlayer: class, Codable {
    var name: String { get }
    var team: Team? { get }
    var isGameMaster: Bool { get }
    var money: GameVariable<Int> { get }
    var currentCargoWeight: Int { get }
    var weightCapacity: Int { get }
    var state: GameVariable<PlayerState> { get }
    var node: Node? { get }
    var nodeIdVariable: GameVariable<Int> { get }
    var hasRolled: Bool { get }
    var deviceId: String { get }
    var map: Map? { get set }
    var gameState: GenericGameState? { get set }
    // for events
    var playerShip: ShipAPI? { get }
    var homeNode: Int { get }

    func addShipsToMap(map: Map)

    // update money
    func updateMoney(to amount: Int)
    func updateMoney(by amount: Int)
    func canBuyUpgrade() -> Bool

    // Subscribes
    func subscribeToItems(with observer: @escaping (GenericPlayer, [GenericItem]) -> Void)
    func subscribeToCargoWeight(with observer: @escaping (GenericPlayer, Int) -> Void)
    func subscribeToWeightCapcity(with observer: @escaping (GenericPlayer, Int) -> Void)
    func subscribeToMoney(with observer: @escaping (GenericPlayer, Int) -> Void)

    // Before moving
    func startTurn(speedMultiplier: Double, map: Map?)
    func buyUpgrade(upgrade: Upgrade) -> (Bool, InfoMessage?)
    func roll() -> (Int, [Int])

    // Moving - Auto progress to End turn if cannot dock
    func move(nodeId: Int)
    func getPath(to nodeId: Int) -> [Int]
    func getNodesInRange(roll: Int) -> [Node]

    // After moving can choose to dock
    func canDock() -> Bool
    func dock() throws
    func getPirateEncounterChance(at nodeId: Int) -> Double

    // Docked - End turn is manual here
    func getPurchasableItemParameters() -> [ItemParameter]
    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int
    func buy(itemParameter: ItemParameter, quantity: Int) throws
    func sell(itemParameter: ItemParameter, quantity: Int) throws
    func setTax(port: Port, amount: Int) throws

    // End turn - supplies are removed here
    func endTurn() -> [InfoMessage]

    func canTradeAt(port: Port) -> Bool
}

func == (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return lhs.name == rhs?.name
}

func != (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return !(lhs == rhs)
}
