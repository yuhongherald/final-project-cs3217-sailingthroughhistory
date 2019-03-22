//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class Ship {
    var name: String {
        return owner?.name ?? "NPC Ship"
    }

    let location: GameVariable<Location>

    private let suppliesConsumed: [GenericItem]
    private var isChasedByPirates = false
    private var turnsToBeingCaught = 0

    private var owner: GenericPlayer?
    private var items = GameVariable<[GenericItem]>(value: [])
    private var currentCargoWeight = GameVariable<Int>(value: 0)
    private var weightCapacity = GameVariable<Int>(value: 100)

    private var shipChassis: ShipChassis?
    private var auxiliaryUpgrade: AuxiliaryUpgrade?
    private var shipUI: ShipUI?

    init(node: Node, suppliesConsumed: [GenericItem]) {
        let location = Location(start: node, end: node, fractionToEnd: 0, isDocked: node is Port)
        self.location = GameVariable(value: location)
        self.suppliesConsumed = suppliesConsumed

        subscribeToItems(with: updateCargoWeight)
        shipUI = ShipUI(ship: self)
    }

    func installUpgade(upgrade: Upgrade) {
        guard let owner = owner else {
            return
        }
        if owner.money.value < upgrade.cost {
            owner.interface?.pauseAndShowAlert(titled: "Insufficient Money!", withMsg: "You do not have sufficient funds to buy \(upgrade.name)!")
        }
        if shipChassis == nil, let shipUpgrade = upgrade as? ShipChassis {
            owner.money.value -= upgrade.cost
            shipChassis = shipUpgrade
            owner.interface?.pauseAndShowAlert(titled: "Ship upgrade purchased!", withMsg: "You have purchased \(upgrade.name)!")
            weightCapacity.value = shipUpgrade.getNewCargoCapacity(baseCapacity: weightCapacity.value)
            return
        }
        if auxiliaryUpgrade == nil, let auxiliary = upgrade as? AuxiliaryUpgrade {
            owner.money.value -= upgrade.cost
            auxiliaryUpgrade = auxiliary
            owner.interface?.pauseAndShowAlert(titled: "Ship upgrade purchased!", withMsg: "You have purchased \(upgrade.name)!")
            return
        }
        if upgrade is ShipChassis {
            owner.interface?.pauseAndShowAlert(titled: "\(owner.name): Upgrade of similar type already purchased!", withMsg: "You already have an upgrade of type \"Ship Upgrade\"!")
        } else if upgrade is AuxiliaryUpgrade {
            owner.interface?.pauseAndShowAlert(titled: "\(owner.name): Upgrade of similar type already purchased!", withMsg: "You already have an upgrade of type \"Auxiliary Upgrade\"!")
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
            owner?.interface?.pauseAndShowAlert(titled: "Unable to Dock!", withMsg: "Ship is not located at a port for docking.")
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
        return port.getItemParametersSold()
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return 0
        }
        guard let unitValue = port.getBuyValue(of: itemParameter.itemType) else {
            return 0
        }
        return min(owner?.money.value ?? 0 / unitValue, getRemainingCapacity() / itemParameter.unitWeight)
    }

    func buyItem(itemParameter: ItemParameter, quantity: Int) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            owner?.interface?.pauseAndShowAlert(titled: "Not docked!", withMsg: "Unable to buy item as ship is not docked.")
            return
        }
        let item = itemParameter.createItem(quantity: quantity)
        guard let price = item.getBuyValue(at: port) else {
            // TODO
            owner?.interface?.pauseAndShowAlert(titled: "Not available!", withMsg: "Unable to buy item as you have insufficient funds.")
            return
        }
        if price > owner?.money.value ?? 0 {
            return
        }
        owner?.money.value -= price
        if addItem(item: item) {
            owner?.interface?.pauseAndShowAlert(titled: "Item purchased!", withMsg: "You have purchased \(item.quantity) of \(item.itemParameter.displayName)")
        } else {
            // TODO
            owner?.interface?.pauseAndShowAlert(titled: "Failed to buy Item!", withMsg: "")
        }
    }

    // TODO: Show errors
    func sellItem(item: GenericItem) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            return
        }
        guard let index = items.value.firstIndex(where: {$0 == item}) else {
            return
        }
        guard let profit = items.value[index].sell(at: port) else {
            return
        }
        owner?.money.value += profit
        items.value.remove(at: index)
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
        return weightCapacity.value - currentCargoWeight.value
    }

    private func addItem(item: GenericItem) -> Bool {
        if getRemainingCapacity() < item.unitWeight {
            return false
        }
        guard let sameType = items.value.first(where: { $0.itemParameter == item.itemParameter }) else {
            items.value.append(item)
            return true
        }
        _ = sameType.combine(with: item)
        return true
    }

    private func consumeRequiredItem(itemParameter: ItemParameter, quantity: Int) -> Int {
        guard let index = items.value.firstIndex(where: { $0.itemParameter == itemParameter }) else {
            return quantity
        }
        guard let consumable = items.value[index] as? GenericConsumable else {
            return 0
        }
        let deficeit = consumable.consume(amount: quantity)
        // TODO: notify others
        if items.value[index].quantity == 0 {
            items.value.remove(at: index)
        }
        guard deficeit <= 0 else {
            return consumeRequiredItem(itemParameter: itemParameter, quantity: deficeit)
        }
        return 0
    }

}

// MARK - Observable values
extension Ship {
    func subscribeToItems(with observer: @escaping (Event<[GenericItem]>) -> Void) {
        items.subscribe(with: observer)
    }

    func subscribeToCargoWeight(with observer: @escaping (Event<Int>) -> Void) {
        currentCargoWeight.subscribe(with: observer)
    }

    func subscribeToWeightCapcity(with observer: @escaping (Event<Int>) -> Void) {
        weightCapacity.subscribe(with: observer)
    }

    private func updateCargoWeight(event: Event<[GenericItem]>) {
        var result = 0
        for item in items.value {
            result += item.unitWeight
        }
        currentCargoWeight.value = result
    }
}
