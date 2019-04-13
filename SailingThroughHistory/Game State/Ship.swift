//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import UIKit

class Ship: Codable {
    var name: String {
        return owner?.name ?? "NPC Ship"
    }

    var isChasedByPirates = false
    var turnsToBeingCaught = 0
    var shipChassis: ShipChassis?
    var auxiliaryUpgrade: AuxiliaryUpgrade?

    private let suppliesConsumed: [GenericItem]

    var nodeId: Int {
        get {
            return nodeIdVariable.value
        }
        set {
            nodeIdVariable.value = newValue
        }
    }
    var currentCargoWeight: Int {
        return currentCargoWeightVariable.value
    }
    var weightCapacity: Int {
        get {
            return weightCapacityVariable.value
        }
        set(value) {
            weightCapacityVariable.value = weightCapacity
        }
    }
    let nodeIdVariable: GameVariable<Int> // public for events
    weak var owner: GenericPlayer?
    var items = GameVariable<[GenericItem]>(value: []) // public for events
    var isDocked = false
    private var currentCargoWeightVariable = GameVariable<Int>(value: 0)
    private var weightCapacityVariable = GameVariable<Int>(value: 100)

    var shipObject: ShipUI?

    weak var map: Map? {
        didSet {
            self.nodeId = self.nodeIdVariable.value
        }
    }

    init(node: Node, suppliesConsumed: [GenericItem]) {
        self.nodeIdVariable = GameVariable(value: node.identifier)
        self.suppliesConsumed = suppliesConsumed

        subscribeToItems(with: updateCargoWeight)
        shipObject = ShipUI(ship: self)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodeIdVariable = GameVariable(value: try values.decode(Int.self, forKey: .nodeID))
        suppliesConsumed = try values.decode([Item].self, forKey: .items)
        items.value = try values.decode([Item].self, forKey: .items)

        if values.contains(.auxiliaryUpgrade) {
            let auxiliaryType = try values.decode(UpgradeType.self, forKey: .auxiliaryUpgrade)
            auxiliaryUpgrade = auxiliaryType.toUpgrade() as? AuxiliaryUpgrade
        }

        if values.contains(.shipChassis) {
            let shipChassisType = try values.decode(UpgradeType.self, forKey: .shipChassis)
            shipChassis = shipChassisType.toUpgrade() as? ShipChassis
        }

        shipObject = ShipUI(ship: self)
    }

    func encode(to encoder: Encoder) throws {
        guard let suppliesConsumed = suppliesConsumed as? [Item],
            let shipItems = items.value as? [Item] else {
                return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeId, forKey: .nodeID)
        try container.encode(suppliesConsumed, forKey: .suppliesConsumed)
        try container.encode(shipItems, forKey: .items)
        if let shipChassis = shipChassis {
            try container.encode(shipChassis.type, forKey: .shipChassis)
        }
        if let auxiliaryUpgrade = auxiliaryUpgrade {
            try container.encode(auxiliaryUpgrade.type, forKey: .auxiliaryUpgrade)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case nodeID
        case suppliesConsumed
        case items
        case shipChassis
        case auxiliaryUpgrade
    }

    func setOwner(owner: GenericPlayer) {
        self.owner = owner
        for item in items.value {
            guard let itemParameter = owner.getItemParameter(itemType: item.itemType) else {
                continue
            }
            item.setItemParameter(itemParameter)
        }
    }

    func setMap(map: Map) {
        guard let shipUI = shipObject else {
            return
        }
        self.map = map
        map.addGameObject(gameObject: shipUI)
    }

    // Movement

    func startTurn() {
    }

    func endTurn(speedMultiplier: Double) -> [InfoMessage] {
        var messages = [InfoMessage]()
        if isChasedByPirates {
            turnsToBeingCaught -= 1
        }

        if isChasedByPirates && turnsToBeingCaught <= 0 {
            isChasedByPirates = false
            turnsToBeingCaught = 0
            items.value.removeAll()
            messages.append(InfoMessage(title: "Pirates!", message: "You have been caught by pirates!. You lost all your cargo"))
        }

        for supply in suppliesConsumed {
            guard let parameter = supply.itemParameter else {
                continue
            }
            let type = supply.itemType
            let deficit = removeItem(by: type, with: Int(Double(supply.quantity) * speedMultiplier))
            owner?.updateMoney(by: -deficit * parameter.getBuyValue())
            messages.append(InfoMessage(title: "deficit!",
                               message: "You have exhausted \(parameter.displayName) and have a deficit of \(deficit) and paid for it."))
        }

        // decay remaining items
        for item in items.value {
            guard let lostQuantity = item.decayItem(with: speedMultiplier) else {
                continue
            }
            messages.append(InfoMessage(title: "Lost Item",
                        message: "You have lost \(lostQuantity) of \(item.itemParameter?.displayName ?? "") from decay and have \(item.quantity) remaining!"))
        }
        return messages
    }

    func getCurrentNode() -> Node {
        guard let map = map, let node = map.nodeIDPair[nodeId] else {
            fatalError("Ship does not reside on any map or nodeId is invalid.")
        }
        return node
    }

}

// Mark : - Item Manipulation
extension Ship {
    func getPurchasableItemTypes() -> [ItemType] {
        guard let port = getCurrentNode() as? Port, isDocked else {
            return []
        }
        return port.itemParametersSoldByPort
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        guard let map = map else {
            fatalError("Ship does not reside on any map.")
        }
        guard let port = map.nodeIDPair[nodeId] as? Port, isDocked,
            let unitValue = port.getBuyValue(of: itemParameter) else {
                return 0
        }
        return min(owner?.money.value ?? 0 / unitValue, getRemainingCapacity() / itemParameter.unitWeight)
    }

    func buyItem(itemType: ItemType, quantity: Int) throws {
        guard let port = getCurrentNode() as? Port, isDocked else {
            throw BuyItemError.notDocked
        }
        guard let itemParameter = owner?.getItemParameter(itemType: itemType) else {
            throw BuyItemError.unknownItem
        }
        let item = itemParameter.createItem(quantity: quantity)
        guard let price = item.getBuyValue(at: port) else {
            throw BuyItemError.itemNotAvailable
        }
        let difference = (owner?.money.value ?? 0) - price
        guard difference >= 0 else {
            throw BuyItemError.insufficientFunds(shortOf: difference)
        }
        owner?.updateMoney(by: -price)
        try addItem(item: item)
        throw BuyItemError.purchaseSuccess(item: item)
    }

    func sellItem(item: GenericItem) throws {
        guard let port = getCurrentNode() as? Port, isDocked else {
            throw BuyItemError.notDocked
        }
        guard let itemType = item.itemParameter else {
            throw BuyItemError.unknownItem
        }
        guard let index = items.value.firstIndex(where: {$0 == item}) else {
            throw BuyItemError.itemNotAvailable
        }
        guard let profit = items.value[index].sell(at: port) else {
            throw BuyItemError.itemNotAvailable
        }
        owner?.updateMoney(by: profit)
        items.value.remove(at: index)
        items.value = items.value
        throw BuyItemError.sellSuccess(item: item)
    }

    func sell(itemType: ItemType, quantity: Int) throws {
        guard let map = map, let port = map.nodeIDPair[nodeId] as? Port else {
            throw BuyItemError.notDocked
        }
        guard let value = port.getSellValue(of: itemType) else {
            throw BuyItemError.itemNotAvailable
        }
        let deficit = removeItem(by: itemType, with: quantity)
        owner?.updateMoney(by: (quantity - deficit) * value)
        if deficit > 0 {
            throw BuyItemError.insufficientItems(shortOf: deficit)
        }
        throw BuyItemError.sellTypeSuccess(itemType: itemType, quantity: quantity)
    }

    private func getRemainingCapacity() -> Int {
        return weightCapacity - currentCargoWeight
    }

    private func addItem(item: GenericItem) throws {
        let difference = getRemainingCapacity() - (item.weight ?? 0)
        guard difference >= 0 else {
            throw BuyItemError.insufficientFunds(shortOf: difference)
        }
        guard let sameType = items.value.first(where: { $0.itemParameter == item.itemParameter }) else {
            items.value.append(item)
            items.value = items.value
            return
        }
        _ = sameType.combine(with: item)
        return
    }

    private func removeItem(by itemType: ItemType, with quantity: Int) -> Int {
        guard let index = items.value.firstIndex(where: { $0.itemType == itemType }) else {
            return quantity
        }
        let deficit = items.value[index].remove(amount: quantity)
        if items.value[index].quantity == 0 {
            items.value.remove(at: index)
            items.value = items.value
        }
        guard deficit <= 0 else {
            return removeItem(by: itemType, with: deficit)
        }
        return 0
    }

}

// MARK: - Observable values
extension Ship {
    func subscribeToLocation(with observer: @escaping (Node) -> Void) {
        nodeIdVariable.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            guard let map = self.map, let node = map.nodeIDPair[self.nodeId] else {
                return
            }
            observer(node)
        }
    }

    func subscribeToItems(with observer: @escaping ([GenericItem]) -> Void) {
        items.subscribe(with: observer)
    }

    func subscribeToCargoWeight(with observer: @escaping (Int) -> Void) {
        currentCargoWeightVariable.subscribe(with: observer)
    }

    func subscribeToWeightCapcity(with observer: @escaping (Int) -> Void) {
        weightCapacityVariable.subscribe(with: observer)
    }

    private func updateCargoWeight(items: [GenericItem]) {
        var result = 0
        for item in items {
            result += item.weight ?? 0
        }
        currentCargoWeightVariable.value = result
    }
}
