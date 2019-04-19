//
//  Ship_ItemStorage_Extension.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// Mark : - Item Manipulation
extension Ship: ItemStorage {
    func getPurchasableItemParameters() -> [ItemParameter] {
        guard let port = node as? Port, isDocked else {
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

    func buyItem(itemParameter: ItemParameter, quantity: Int) throws {
        guard let port = node as? Port, isDocked else {
            throw TradeItemError.notDocked
        }
        let item = itemParameter.createItem(quantity: quantity)
        guard let price = item.getBuyValue(at: port) else {
            throw TradeItemError.itemNotAvailable
        }
        let difference = (owner?.money.value ?? 0) - price
        guard difference >= 0 else {
            throw TradeItemError.insufficientFunds(shortOf: difference)
        }
        try addItem(item: item)
        owner?.updateMoney(by: -price)
        updateCargoWeight(items: self.items.value)
    }

    func sellItem(item: GenericItem) throws {
        guard let port = node as? Port, isDocked else {
            throw TradeItemError.notDocked
        }
        guard let index = items.value.firstIndex(where: {$0 == item}) else {
            throw TradeItemError.itemNotAvailable
        }
        guard let profit = items.value[index].sell(at: port) else {
            throw TradeItemError.itemNotAvailable
        }
        owner?.updateMoney(by: profit)
        items.value.remove(at: index)
        items.value = items.value
        updateCargoWeight(items: self.items.value)
    }

    func sell(itemParameter: ItemParameter, quantity: Int) throws {
        guard let map = map, let port = map.nodeIDPair[nodeId] as? Port else {
            throw TradeItemError.notDocked
        }
        guard let value = port.getSellValue(of: itemParameter) else {
            throw TradeItemError.itemNotAvailable
        }
        let deficit = removeItem(by: itemParameter, with: quantity)
        owner?.updateMoney(by: (quantity - deficit) * value)
        if deficit > 0 {
            throw TradeItemError.insufficientItems(shortOf: deficit, sold: quantity - deficit)
        }
    }

    func removeItem(by itemParameter: ItemParameter, with quantity: Int) -> Int {
        guard let index = items.value.firstIndex(where: { $0.itemParameter == itemParameter }) else {
            return quantity
        }
        let deficit = items.value[index].remove(amount: quantity)
        if items.value[index].quantity == 0 {
            items.value.remove(at: index)
            items.value = items.value
        }
        guard deficit <= 0 else {
            return removeItem(by: itemParameter, with: deficit)
        }
        return 0
    }

    private func getRemainingCapacity() -> Int {
        return weightCapacity - currentCargoWeight
    }

    private func addItem(item: GenericItem) throws {
        let difference = getRemainingCapacity() - (item.weight ?? 0)
        guard difference >= 0 else {
            throw TradeItemError.insufficientFunds(shortOf: difference)
        }
        guard let sameType = items.value.first(where: { $0.itemParameter == item.itemParameter }) else {
            items.value.append(item)
            items.value = items.value
            return
        }
        _ = sameType.combine(with: item)
        return
    }
}
