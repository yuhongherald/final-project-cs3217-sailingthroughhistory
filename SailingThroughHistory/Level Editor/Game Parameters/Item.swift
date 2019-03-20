//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item: GenericItem {
    var type: ItemType!
    public let itemParameter: ItemParameter
    public var weight: Int {
        return quantity * itemParameter.weight
    }
    // TODO: prevent quantity from going below 0
    public var quantity: Int

    public required init(itemType: ItemParameter, quantity: Int) {
        self.itemParameter = itemType
        self.quantity = quantity
    }

    func combine(with item: GenericItem) -> Bool {
        guard itemParameter == item.itemParameter else {
            return false
        }
        quantity += item.quantity
        item.setQuantity(quantity: 0)
        return true
    }

    func setQuantity(quantity: Int) {
        self.quantity = quantity
    }

    func getBuyValue(at port: Port) -> Int? {
        guard let unitValue = itemParameter.getSellValue(at: port) else {
            // TODO: Error
            return nil
        }
        return unitValue * quantity
    }

    func sell(at port: Port) -> Int? {
        guard let unitValue = itemParameter.getSellValue(at: port) else {
            // TODO: Error
            return nil
        }
        let value = unitValue * quantity
        setQuantity(quantity: 0)
        return value
    }

    func getRemainingQuantity(port: Port) -> Int {
        return quantity
    }
}
