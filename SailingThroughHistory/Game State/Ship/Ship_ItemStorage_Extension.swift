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

    func removeItem(by itemType: ItemType, with quantity: Int) -> Int {
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
}
