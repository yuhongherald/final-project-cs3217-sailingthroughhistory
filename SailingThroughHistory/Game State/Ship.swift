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
    var name: String {
        return owner?.name ?? "NPC Ship"
    }

    let location: GameVariable<Location>

    private let suppliesConsumed: [GenericItem]
    private let defaultWeightCapacity = 100
    private var isChasedByPirates = false
    private var turnsToBeingCaught = 0

    private var owner: GenericPlayer?
    private var items = [GenericItem]()
    private var weightCapacity: Int {
        return shipChassis?.getNewCargoCapacity(baseCapacity: defaultWeightCapacity) ?? defaultWeightCapacity
    }

    private var shipChassis: ShipChassis?
    private var auxiliaryUpgrade: AuxiliaryUpgrade?
    private var shipUI: ShipUI?

    init(node: Node, suppliesConsumed: [GenericItem]) {
        let location = Location(start: node, end: node, fractionToEnd: 0, isDocked: node is Port)
        self.location = GameVariable(value: location)
        self.suppliesConsumed = suppliesConsumed

        shipUI = ShipUI(ship: self)
    }

    func installUpgade(upgrade: Upgrade) {
        if owner?.money.value ?? 0 < upgrade.cost {
            // TODO: not enough money
        }
        if shipChassis == nil, let shipUpgrade = upgrade as? ShipChassis {
            owner?.money.value -= upgrade.cost
            shipChassis = shipUpgrade
            // TODO: Success prompt
            return
        }
        if auxiliaryUpgrade == nil, let auxiliary = upgrade as? AuxiliaryUpgrade {
            owner?.money.value -= upgrade.cost
            auxiliaryUpgrade = auxiliary
            // TODO: Success prompt
            return
        }
    }

    func setOwner(owner: GenericPlayer?) {
        self.owner = owner
    }

    // Movement

    func startTurn() {
        if isChasedByPirates && turnsToBeingCaught <= 0 {
            // TODO: Pirate event

            isChasedByPirates = false
            turnsToBeingCaught = 0
        }
    }

    func getNodesInRange(roll: Int) -> [Node] {
        let movement = computeMovement(roll: roll)
        let nodesFromStart = location.value.start.getNodesInRange(range: movement - location.value.fractionToEnd)
        if location.value.fractionToEnd == 0 {
            return nodesFromStart
        }
        let nodesFromEnd = location.value.end.getNodesInRange(range: movement + 1 - location.value.fractionToEnd)
        return Array(Set(nodesFromStart + nodesFromEnd))
    }

    func move(node: Node) {
        location.value = Location(start: node, end: node, fractionToEnd: 0, isDocked: false)
    }

    func canDock() -> Bool {
        return location.value.fractionToEnd == 0 && location.value.start is Port
    }

    func dock() -> Port? {
        guard canDock() else {
            // TODO: Show some error
            return nil
        }
        guard let port = location.value.start as? Port else {
            return nil
        }
        location.value = Location(from: location.value, isDocked: true)
        isChasedByPirates = false
        turnsToBeingCaught = 0
        return port
    }

    // Items

    func getPurchasableItemParameters() -> [ItemParameter] {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return []
        }
        return port.itemParametersSold
    }

    func getItems() -> [GenericItem] {
        return items
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return 0
        }
        guard let unitValue = itemParameter.getBuyValue(at: port) else {
            return 0
        }
        return min(owner?.money.value ?? 0 / unitValue, getRemainingCapacity() / itemParameter.weight)
    }

    // TODO: show errors
    func buyItem(itemParameter: ItemParameter, quantity: Int) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return
        }
        let item = itemParameter.createItem(quantity: quantity)
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
    func sellItem(item: GenericItem) {
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

    func endTurn() {
        if isChasedByPirates {
            turnsToBeingCaught -= 1
        }

        for supply in suppliesConsumed {
            let deficeit = consumeRequiredItem(itemParameter: supply.itemParameter, quantity: supply.quantity)
            // TODO: Make player pay for deficeit
        }
    }

    // Helper functions

    private func computeMovement(roll: Int) -> Double {
        var multiplier = 1.0
        multiplier = applyMovementModifiers(to: multiplier)
        return Double(roll) * multiplier
    }

    private func applyMovementModifiers(to multiplier: Double) -> Double {
        // TODO: Calculate actual multiplier
        var result = multiplier
        result *= shipChassis?.getMovementModifier() ?? 1
        result *= auxiliaryUpgrade?.getMovementModifier() ?? 1
        return result
    }

    private func getWeatherModifier() -> Double {
        var multiplier = 1.0
        multiplier *= shipChassis?.getWeatherModifier() ?? 1
        multiplier *= auxiliaryUpgrade?.getWeatherModifier() ?? 1
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
        guard let sameType = items.first(where: { $0.itemParameter == item.itemParameter }) else {
            items.append(item)
            return true
        }
        _ = sameType.combine(with: item)
        return true
    }

    private func consumeRequiredItem(itemParameter: ItemParameter, quantity: Int) -> Int {
        guard let index = items.firstIndex(where: { $0.itemParameter == itemParameter }) else {
            return quantity
        }
        guard let consumable = items[index] as? GenericConsumable else {
            return 0
        }
        let deficeit = consumable.consume(amount: quantity)
        if items[index].quantity == 0 {
            items.remove(at: index)
        }
        guard deficeit <= 0 else {
            return consumeRequiredItem(itemParameter: itemParameter, quantity: deficeit)
        }
        return 0
    }
}
