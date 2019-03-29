//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item: GenericItem, Codable {
    var itemType: ItemType? {
        return itemParameter?.itemType
    }
    var itemParameter: ItemParameter?
    var weight: Int? {
        guard let unitWeight = itemParameter?.unitWeight else {
            return nil
        }
        return quantity * unitWeight
    }
    // TODO: prevent quantity from going below 0
    var quantity: Int {
        get {
            return realQuantity
        }
        set(value) {
            guard value >= 0 else {
                // TODO error
                realQuantity = 0
                return
            }
            realQuantity = value
            decimalQuantity = Double(realQuantity)
        }
    }

    private var realQuantity = 0
    private var decimalQuantity = 0.0

    required init(itemType: ItemParameter, quantity: Int) {
        self.itemParameter = itemType
        self.quantity = quantity
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try quantity = values.decode(Int.self, forKey: .quantity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quantity, forKey: .quantity)
    }

    private enum CodingKeys: String, CodingKey {
        case quantity
    }

    func setItemType(_ itemType: ItemParameter) {
        itemParameter = itemType
    }

    func decayItem(with time: Double) -> Int? {
        guard let halfLife = itemParameter?.getHalfLife() else {
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
        guard let itemType = itemType else {
            return nil
        }
        guard let unitValue = port.getBuyValue(of: itemType) else {
            return nil
        }
        return unitValue * quantity
    }

    func sell(at port: Port) -> Int? {
        guard let itemType = itemType else {
            return nil
        }
        guard let unitValue = port.getSellValue(of: itemType) else {
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
