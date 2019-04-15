//
//  GenericPlayerStub.swift
//  SailingThroughHistory
//
//  Created by henry on 14/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GenericPlayerStub: GenericPlayer {
    var isGameMaster = false
    var name: String = ""
    var team: Team?
    var money: GameVariable<Int> = GameVariable(value: 0)
    var currentCargoWeight: Int = 0
    var weightCapacity: Int = 0
    var state: GameVariable<PlayerState> = GameVariable(value: PlayerState.endTurn)
    var node: Node?
    var nodeIdVariable: GameVariable<Int> = GameVariable(value: 0)
    var hasRolled: Bool = false
    var deviceId: String = ""
    var map: Map?
    var gameState: GenericGameState?
    var playerShip: Ship?
    var homeNode: Int = 0

    private let errorMessage = "Stub cannot perform normal actions"

    required init() {
    }

    required init(from decoder: Decoder) throws {
        fatalError(errorMessage)
    }

    func encode(to encoder: Encoder) throws {
        fatalError(errorMessage)
    }

    func getItemParameter(itemType: ItemType) -> ItemParameter? {
        fatalError(errorMessage)
    }

    func addShipsToMap(map: Map) {
        fatalError(errorMessage)
    }

    func updateMoney(to amount: Int) {
        fatalError(errorMessage)
    }

    func updateMoney(by amount: Int) {
        fatalError(errorMessage)
    }

    func canBuyUpgrade() -> Bool {
        fatalError(errorMessage)
    }

    func subscribeToItems(with observer: @escaping (GenericPlayer, [GenericItem]) -> Void) {
        fatalError(errorMessage)
    }

    func subscribeToCargoWeight(with observer: @escaping (GenericPlayer, Int) -> Void) {
        fatalError(errorMessage)
    }

    func subscribeToWeightCapcity(with observer: @escaping (GenericPlayer, Int) -> Void) {
        fatalError(errorMessage)
    }

    func subscribeToMoney(with observer: @escaping (GenericPlayer, Int) -> Void) {
        fatalError(errorMessage)
    }

    func startTurn(speedMultiplier: Double, map: Map?) {
        fatalError(errorMessage)
    }

    func buyUpgrade(upgrade: Upgrade) -> (Bool, InfoMessage?) {
        fatalError(errorMessage)
    }

    func roll() -> (Int, [Int]) {
        fatalError(errorMessage)
    }

    func move(nodeId: Int) {
        fatalError(errorMessage)
    }

    func getPath(to nodeId: Int) -> [Int] {
        fatalError(errorMessage)
    }

    func getNodesInRange(roll: Int) -> [Node] {
        fatalError(errorMessage)
    }

    func canDock() -> Bool {
        fatalError(errorMessage)
    }

    func dock() throws {
        fatalError(errorMessage)
    }

    func getPirateEncounterChance() -> Double {
        fatalError(errorMessage)
    }

    func getPurchasableItemTypes() -> [ItemType] {
        fatalError(errorMessage)
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        fatalError(errorMessage)
    }

    func buy(itemType: ItemType, quantity: Int) throws {
        fatalError(errorMessage)
    }

    func sell(item: GenericItem) throws {
        fatalError(errorMessage)
    }

    func sell(itemType: ItemType, quantity: Int) throws {
        fatalError(errorMessage)
    }

    func setTax(port: Port, amount: Int) {
        fatalError(errorMessage)
    }

    func endTurn() -> [InfoMessage] {
        fatalError(errorMessage)
    }

    func canTradeAt(port: Port) -> Bool {
        fatalError(errorMessage)
    }
}
