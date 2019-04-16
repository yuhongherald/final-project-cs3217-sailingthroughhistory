//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Ship: Codable {
    let suppliesConsumed: [GenericItem]

    var name: String {
        return owner?.name ?? "NPC Ship"
    }
    var isChasedByPirates = false
    var turnsToBeingCaught = 0
    var shipChassis: ShipChassis?
    var auxiliaryUpgrade: AuxiliaryUpgrade?

    var nodeId: Int {
        get {
            return nodeIdVariable.value
        }
        set {
            nodeIdVariable.value = newValue
        }
    }
    var node: Node {
        guard let map = map, let currentNode = map.nodeIDPair[nodeId] else {
            fatalError("Ship does not reside on any map or nodeId is invalid.")
        }
        return currentNode
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
            guard let map = map,
                let shipUI = shipObject else {
                return
            }
            /// Move ship to its node
            self.nodeId = self.nodeIdVariable.value
            map.addGameObject(gameObject: shipUI)
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
            let type = supply.itemType
            let deficit = removeItem(by: type, with: Int(Double(supply.quantity) * speedMultiplier))
            let parameter = supply.itemParameter
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
                        message: "You have lost \(lostQuantity) of \(item.itemParameter.displayName ?? "") from decay and have \(item.quantity) remaining!"))
        }
        return messages
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
