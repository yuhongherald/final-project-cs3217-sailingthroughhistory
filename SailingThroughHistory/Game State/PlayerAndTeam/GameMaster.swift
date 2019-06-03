//
//  GameMaster.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents a Game Master in the game. The Game Master is a Player without normal
/// Player Actions, such as moving a Ship or buying/selling Items. A Game Master can
/// set events in the game.
import Foundation

class GameMaster: GenericPlayer {
    var name: String
    var team: Team?
    let isGameMaster = true
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
    var playerShip: ShipAPI?
    var homeNode: Int = 0

    private let errorMessage = "GameMaster cannot perform normal actions"

    required init(name: String, deviceId: String) {
        self.name = name
        self.deviceId = deviceId
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        deviceId = try values.decode(String.self, forKey: .deviceId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(deviceId, forKey: .deviceId)
    }
    private enum CodingKeys: String, CodingKey {
        case name
        case deviceId
    }

    func addShipsToMap(map: Map) {
        return
    }

    func updateMoney(to amount: Int) {
        return
    }

    func updateMoney(by amount: Int) {
        return
    }

    func canBuyUpgrade() -> Bool {
        return false
    }

    func subscribeToItems(with observer: @escaping (GenericPlayer, [GenericItem]) -> Void) {
        return
    }

    func subscribeToCargoWeight(with observer: @escaping (GenericPlayer, Int) -> Void) {
        return
    }

    func subscribeToWeightCapcity(with observer: @escaping (GenericPlayer, Int) -> Void) {
        return
    }

    func subscribeToMoney(with observer: @escaping (GenericPlayer, Int) -> Void) {
        return
    }

    func startTurn(speedMultiplier: Double, map: Map?) {
        return
    }

    func buyUpgrade(upgrade: Upgrade) -> (Bool, InfoMessage?) {
        return (false, nil)
    }

    func roll() -> (Int, [Int]) {
        fatalError(errorMessage)
    }

    func move(nodeId: Int) {
        return
    }

    func getPath(to nodeId: Int) -> [Int] {
        fatalError(errorMessage)
    }

    func getNodesInRange(roll: Int) -> [Node] {
        fatalError(errorMessage)
    }

    func canDock() -> Bool {
        return false
    }

    func dock() throws {
        return
    }

    func getPirateEncounterChance(at nodeId: Int) -> Double {
        return 0
    }

    func getPurchasableItemParameters() -> [ItemParameter] {
        fatalError(errorMessage)
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        fatalError(errorMessage)
    }

    func buy(itemParameter: ItemParameter, quantity: Int) throws {
        return
    }

    func sell(item: GenericItem) throws {
        return
    }

    func sell(itemParameter: ItemParameter, quantity: Int) throws {
        return
    }

    func setTax(port: Port, amount: Int) {
        return
    }

    func endTurn() -> [InfoMessage] {
        return []
    }

    func canTradeAt(port: Port) -> Bool {
        return false
    }
}
