//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item: GenericItem {
    public let itemType: GenericItemType
    public var weight: Int {
        return quantity * itemType.weight
    }
    // TODO: prevent quantity from going below 0
    public var quantity: Int

    public required init(itemType: GenericItemType, quantity: Int) {
        self.itemType = itemType
        self.quantity = quantity
    }

    func combine(with item: GenericItem) -> Bool {
        guard itemType == item.itemType else {
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
        guard let unitValue = itemType.getSellValue(at: port) else {
            // TODO: Error
            return nil
        }
        return unitValue * quantity
    }

    func sell(at port: Port) -> Int? {
        guard let unitValue = itemType.getSellValue(at: port) else {
            // TODO: Error
            return nil
        }
        let value = unitValue * quantity
        setQuantity(quantity: 0)
        return value
    }
}
