//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents a Ship in the game. Assumes a non-negative baseCapacity. This class
/// supports only the main interactions between Player and Ship. The rest of the
/// behaviors are defined by itemManager, upgradeManager and navigationManager.
import Foundation

class Ship: ShipAPI, Codable {
    private static let baseCapacity = 100

    let itemManager: ItemStorage = ShipItemManager()
    let upgradeManager: Upgradable = ShipUpgradeManager()
    let navigationManager: Navigatable = ShipNavigationManager()

    let itemsConsumed: [GenericItem]
    var name: String {
        return owner?.name ?? "NPC Ship"
    }
    var isChasedByPirates = false
    var turnsToBeingCaught = 0
    var shipChassis: ShipChassis? {
        didSet {
            guard let newCapacity = shipChassis?.getNewCargoCapacity(baseCapacity: Ship.baseCapacity) else {
                return
            }
            weightCapacity = newCapacity
        }
    }
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
            weightCapacityVariable.value = value
        }
    }
    let nodeIdVariable: GameVariable<Int> // public for events
    weak var owner: GenericPlayer?
    var items = GameVariable<[GenericItem]>(value: []) // public for events
    var isDocked = false

    private var currentCargoWeightVariable = GameVariable<Int>(value: 0)
    private var weightCapacityVariable = GameVariable<Int>(value: Ship.baseCapacity)

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

    init(node: Node, itemsConsumed: [GenericItem]) {
        self.nodeIdVariable = GameVariable(value: node.identifier)
        self.itemsConsumed = itemsConsumed

        subscribeToItems(with: updateCargoWeight)
        shipObject = ShipUI(ship: self)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodeIdVariable = GameVariable(value: try values.decode(Int.self, forKey: .nodeID))
        itemsConsumed = try values.decode([Item].self, forKey: .itemsConsumed)
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
        updateCargoWeight(items: items.value)
        subscribeToItems(with: updateCargoWeight)
    }

    func encode(to encoder: Encoder) throws {
        guard let itemsConsumed = itemsConsumed as? [Item],
            let shipItems = items.value as? [Item] else {
                return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeId, forKey: .nodeID)
        try container.encode(itemsConsumed, forKey: .itemsConsumed)
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
        case itemsConsumed
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
        if turnsToBeingCaught > 0 {
            messages.append(InfoMessage.pirates(turnsToBeingCaught: turnsToBeingCaught))
        }

        if isChasedByPirates && turnsToBeingCaught <= 0 && !isDocked {
            isChasedByPirates = false
            turnsToBeingCaught = 0
            items.value.removeAll()
            messages.append(InfoMessage.caughtByPirates)
        }

        for supply in itemsConsumed {
            let parameter = supply.itemParameter
            let deficit = itemManager.removeItem(ship: self, by: parameter,
                                                 with: Int(Double(supply.quantity) * speedMultiplier))
            if let owner = owner,
                let ports = owner.map?.nodes.value.map({ $0 as? Port }).compactMap({ $0 }), deficit > 0 {
                owner.updateMoney(by: -deficit * 2 * parameter.getBuyValue(ports: ports))
                messages.append(InfoMessage.deficit(itemName: parameter.rawValue, deficit: deficit))
            }
        }
        updateCargoWeight(items: self.items.value)
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

    func updateCargoWeight(items: [GenericItem]) {
        var result = 0
        for item in items {
            result += item.weight
        }
        currentCargoWeightVariable.value = result
    }
}

// MARK: - Affected by Pirates and Weather
extension Ship {
    func startPirateChase() {
        if isChasedByPirates {
            return
        }
        isChasedByPirates = true
        turnsToBeingCaught = 4
    }
    func getWeatherModifier() -> Double {
        return auxiliaryUpgrade?.getWeatherModifier() ?? 1.0
    }
}
