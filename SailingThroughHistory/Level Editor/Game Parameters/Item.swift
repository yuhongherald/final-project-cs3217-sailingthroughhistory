//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item: GenericItem, Codable {
    var name: String {
        return itemParameter.rawValue
    }
    let itemParameter: ItemParameter
    var weight: Int? {
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

    func decayItem(with time: Double) -> Int? {
        guard let halfLife = itemParameter.getHalfLife() else {
            return nil
        }
        decimalQuantity /= pow(M_E, M_LN2 / Double(halfLife))
        let diff = Int(realQuantity - Int(decimalQuantity))
        guard diff >= 1 else {
            return nil
        }
        realQuantity -= diff
        return diff
    }

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

    func getBuyValue(at port: Port) -> Int? {
        guard let unitValue = port.getBuyValue(of: itemParameter) else {
            return nil
        }
        return unitValue * quantity
    }

    func sell(at port: Port) -> Int? {
        guard let unitValue = port.getSellValue(of: itemParameter) else {
            return nil
        }
        let value = unitValue * quantity
        quantity = 0
        return value
    }

    private enum CodingKeys: String, CodingKey {
        case quantity
        case itemParameter
    }
}
