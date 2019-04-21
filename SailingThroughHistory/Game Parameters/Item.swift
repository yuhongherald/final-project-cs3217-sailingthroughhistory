//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * Model for item to store item parameter, total weight and quantity.
 */
class Item: GenericItem, Codable {
    var name: String {
        return itemParameter.rawValue
    }
    let itemParameter: ItemParameter
    var weight: Int {
        let unitWeight = itemParameter.unitWeight
        return quantity * unitWeight
    }
    var quantity: Int {
        get {
            return realQuantity
        }
        set(value) {
            guard value >= 0 else {
                print("Tried to set item quantity below 0.")
                realQuantity = 0
                return
            }
            realQuantity = value
            decimalQuantity = Double(realQuantity)
        }
    }

    private var realQuantity = 0
    private var decimalQuantity = 0.0

    init(itemParameter: ItemParameter, quantity: Int) {
        self.itemParameter = itemParameter
        self.quantity = quantity
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try itemParameter = values.decode(ItemParameter.self, forKey: .itemParameter)
        try quantity = values.decode(Int.self, forKey: .quantity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(itemParameter, forKey: .itemParameter)
        try container.encode(quantity, forKey: .quantity)
    }

    /// Combine items with the same type.
    /// - Parameters:
    ///   - item: another item intend to be combined.
    /// - Returns:
    ///   If item is of the same type, return true.
    ///   If item is of different type, return false.
    func combine(with item: inout GenericItem) -> Bool {
        guard itemParameter == item.itemParameter else {
            return false
        }
        quantity += item.quantity
        item.quantity = 0
        return true
    }

    /// Remove Item quantity by input amount.
    /// - Returns:
    ///   If Item quantity is enough, return 0.
    ///   If Item quantity is not enough, return deficit as positive integer.
    func remove(amount: Int) -> Int {
        if quantity < amount {
            let deficit = amount - quantity
            quantity = 0
            return deficit
        }
        quantity -= amount
        return 0
    }

    /// Get the money user needs to pay for buying the item at port.
    func getBuyValue(at port: Port) -> Int? {
        guard let unitValue = port.getBuyValue(of: itemParameter) else {
            return nil
        }
        return unitValue * quantity
    }

    /// Get the money user can gain for selling the item to port.
    func sell(at port: Port) -> Int? {
        guard let unitValue = port.getSellValue(of: itemParameter) else {
            return nil
        }
        let value = unitValue * quantity
        quantity = 0
        return value
    }

    /// Get a copy of current item with the same itemParameter and quantity.
    func copy() -> Item {
        return Item(itemParameter: itemParameter, quantity: quantity)
    }

    private enum CodingKeys: String, CodingKey {
        case quantity
        case itemParameter
    }
}
