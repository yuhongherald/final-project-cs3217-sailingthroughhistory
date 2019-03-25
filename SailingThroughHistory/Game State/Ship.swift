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
            showMessage(titled: "Insufficient Money!", withMsg: "You do not have sufficient funds to buy \(upgrade.name)!")
        }
        if shipChassis == nil, let shipUpgrade = upgrade as? ShipChassis {
            owner.money.value -= upgrade.cost
            shipChassis = shipUpgrade
            showMessage(titled: "Ship upgrade purchased!", withMsg: "You have purchased \(upgrade.name)!")
            weightCapacity.value = shipUpgrade.getNewCargoCapacity(baseCapacity: weightCapacity.value)
            return
        }
        if auxiliaryUpgrade == nil, let auxiliary = upgrade as? AuxiliaryUpgrade {
            owner.money.value -= upgrade.cost
            auxiliaryUpgrade = auxiliary
            showMessage(titled: "Ship upgrade purchased!", withMsg: "You have purchased \(upgrade.name)!")
            return
        }
        if upgrade is ShipChassis {
            showMessage(titled: "\(owner.name): Upgrade of similar type already purchased!", withMsg: "You already have an upgrade of type \"Ship Upgrade\"!")
        } else if upgrade is AuxiliaryUpgrade {
            showMessage(titled: "\(owner.name): Upgrade of similar type already purchased!", withMsg: "You already have an upgrade of type \"Auxiliary Upgrade\"!")
        }
    }

    func setOwner(owner: GenericPlayer?) {
        self.owner = owner
    }

    // Movement

    func startTurn() {
        if isChasedByPirates && turnsToBeingCaught <= 0 {
            // TODO: Pirate event
            showMessage(titled: "Pirates!", withMsg: "You have been caught by pirates!. You lost all your cargo")

            isChasedByPirates = false
            turnsToBeingCaught = 0
        }
    }

    func getNodesInRange(roll: Int, speedMultiplier: Double, map: Map?) -> [Node] {
        guard let map = map else {
            showMessage(titled: "Unable to move", withMsg: "Game does not have a map registered!")
            return []
        }
        let movement = computeMovement(roll: roll, speedMultiplier: speedMultiplier)
        let nodesFromStart = location.value.start.getNodesInRange(ship: self, range: movement - location.value.fractionToEnd, map: map)
        if location.value.fractionToEnd == 0 {
            return nodesFromStart
        }
        let nodesFromEnd = location.value.end.getNodesInRange(ship: self, range: movement + 1 - location.value.fractionToEnd, map: map)
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
            showMessage(titled: "Unable to Dock!", withMsg: "Ship is not located at a port for docking.")
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
            showMessage(titled: "Not docked!", withMsg: "Unable to buy item as ship is not docked.")
            return
        }
        let item = itemParameter.createItem(quantity: quantity)
        guard let price = item.getBuyValue(at: port) else {
            showMessage(titled: "Not available!", withMsg: "Item is not available for purchase at current port!")
            return
        }
        if price > owner?.money.value ?? 0 {
            return
        }
        owner?.money.value -= price
        if addItem(item: item) {
            showMessage(titled: "Item purchased!", withMsg: "You have purchased \(item.quantity) of \(item.itemParameter.displayName)")
        } else {
            showMessage(titled: "Failed to buy Item!", withMsg: "An error has occurred in the game!")
        }
    }

    func sellItem(item: GenericItem) {
        guard let port = location.value.start as? Port, location.value.isDocked else {
            showMessage(titled: "Not docked!", withMsg: "Unable to sell item as ship is not docked.")
            return
        }
        guard let index = items.value.firstIndex(where: {$0 == item}) else {
            showMessage(titled: "Not available!", withMsg: "Item cannot be sold at current port!")
            return
        }
        guard let profit = items.value[index].sell(at: port) else {
            showMessage(titled: "Item sold!", withMsg: "You have sold \(item.quantity) of \(item.itemParameter.displayName)")
            return
        }
        owner?.money.value += profit
        items.value.remove(at: index)
        items.value = items.value
    }

    func endTurn(speedMultiplier: Double) {
        if isChasedByPirates {
            turnsToBeingCaught -= 1
        }

        for supply in suppliesConsumed {
            let deficeit = consumeRequiredItem(itemParameter: supply.itemParameter, quantity: Int(Double(supply.quantity) * speedMultiplier))
            // TODO: Make player pay for deficeit
        }
    }

    // Helper functions

    private func computeMovement(roll: Int, speedMultiplier: Double) -> Double {
        var multiplier = 1.0
        multiplier = applyMovementModifiers(to: multiplier)
        return Double(roll) * speedMultiplier * multiplier
    }

    private func applyMovementModifiers(to multiplier: Double) -> Double {
        var result = multiplier
        result *= shipChassis?.getMovementModifier() ?? 1
        result *= auxiliaryUpgrade?.getMovementModifier() ?? 1
        return result
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
            items.value = items.value
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
        if items.value[index].quantity == 0 {
            items.value.remove(at: index)
            items.value = items.value;
        }
        guard deficeit <= 0 else {
            return consumeRequiredItem(itemParameter: itemParameter, quantity: deficeit)
        }
        return 0
    }

}

// MARK: - Observable values
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

// MARK: - Show messages
extension Ship {
    private func showMessage(titled: String, withMsg: String) {
        owner?.interface?.pauseAndShowAlert(titled: titled, withMsg: withMsg)
        owner?.interface?.broadcastInterfaceChanges(withDuration: 0.5)
    }
}

// MARK: - Affected by Pirates and Weather
extension Ship: Pirate_WeatherEntity {
    func startPirateChase() {
        isChasedByPirates = true
        turnsToBeingCaught = 2
        showMessage(titled: "Pirates!", withMsg: "You have ran into pirates! You must dock your ship within \(turnsToBeingCaught) turns or risk losing all your cargo!")
    }
    func getWeatherModifier() -> Double {
        var multiplier = 1.0
        multiplier *= shipChassis?.getWeatherModifier() ?? 1
        multiplier *= auxiliaryUpgrade?.getWeatherModifier() ?? 1
        return multiplier
    }
}
