//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import UIKit

class Ship {
    public var name: String {
        return owner?.name ?? "NPC Ship"
    }

    public let location: GameVariable<Location>

    private var owner: GenericPlayer?
    private var items = [GenericItem]()
    private var weightCapacity = 0
    private var chassis: Upgrade?
    private var axuxiliaryUpgrade: Upgrade?
    private var shipUI: ShipUI?

    public init(node: Node) {
        let location = Location(start: node, end: node, fractionToEnd: 0, isDocked: node is Port)
        self.location = GameVariable(value: location)
        shipUI = ShipUI(ship: self)
    }

    public func setOwner(owner: GenericPlayer?) {
        self.owner = owner
    }

    // Movement

    public func getNodesInRange(roll: Int) -> [Node] {
        let movement = computeMovement(roll: roll)
        let nodesFromStart = location.value.start.getNodesInRange(range: movement - location.value.fractionToEnd)
        if location.value.fractionToEnd == 0 {
            return nodesFromStart
        }
        let nodesFromEnd = location.value.end.getNodesInRange(range: movement + 1 - location.value.fractionToEnd)
        return Array(Set(nodesFromStart + nodesFromEnd))
    }

    public func move(node: Node) {
        location.value = Location(start: node, end: node, fractionToEnd: 0, isDocked: false)
    }

    public func canDock() -> Bool {
        return location.value.fractionToEnd == 0 && location.value.start is Port
    }

    public func dock() -> Port? {
        guard canDock() else {
            // TODO: Show some error
            return nil
        }
        guard let port = location.value.start as? Port else {
            return nil
        }
        location.value = Location(from: location.value, isDocked: true)
        return port
    }

    // Items

    public func getPurchasableItemTypes() -> [GenericItemType] {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return []
        }
        return port.itemTypes
    }

    public func getItems() -> [GenericItem] {
        return items
    }

    public func getMaxPurchaseAmount(itemType: GenericItemType) -> Int {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return 0
        }
        guard let unitValue = itemType.getBuyValue(at: port) else {
            return 0
        }
        return min(owner?.money.value ?? 0 / unitValue, getRemainingCapacity() / itemType.weight)
    }

    // TODO: show errors
    public func buyItem(itemType: GenericItemType, quantity: Int) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return
        }
        let item = itemType.createItem(quantity: quantity)
        guard let price = item.getBuyValue(at: port) else {
            return
        }
        if price > owner?.money.value ?? 0 {
            return
        }
        owner?.money.value -= price
        if addItem(item: item) {
            // TODO: show purchase success
        } else {
        }
    }

    // TODO: Show errors
    public func sellItem(item: GenericItem) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return
        }
        guard let index = items.firstIndex(where: {$0 == item}) else {
            return
        }
        guard let profit = items[index].sell(at: port) else {
            return
        }
        owner?.money.value += profit
        items.remove(at: index)
    }

    // Helper functions

    private func computeMovement(roll: Int) -> Double {
        var multiplier = 1.0
        multiplier = applyUpgradesModifiers(to: multiplier)
        return Double(roll) * multiplier
    }

    private func applyUpgradesModifiers(to multiplier: Double) -> Double {
        return multiplier
    }

    private func getWeatherModifier() -> Double {
        var multiplier = 1.0
        return multiplier
    }

    private func getRemainingCapacity() -> Int {
        var remainingCapacity = weightCapacity
        for item in items {
            remainingCapacity -= item.weight
        }
        return remainingCapacity
    }

    private func addItem(item: GenericItem) -> Bool {
        if getRemainingCapacity() < item.weight {
            return false
        }
        guard let sameType = items.first(where: { $0.itemType == item.itemType }) else {
            items.append(item)
            return true
        }
        _ = sameType.combine(with: item)
        return true
    }

}
