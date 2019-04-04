//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

struct ItemParameter: Codable {
    let displayName: String
    let unitWeight: Int
    let itemType: ItemType
    let isConsumable: Bool

    private var sellValue: Int = Default.Item.sellValue
    private var buyValue: Int = Default.Item.buyValue
    private var halfLife: Int?

    init(itemType: ItemType, displayName: String, weight: Int, isConsumable: Bool) {
        self.itemType = itemType
        self.displayName = displayName
        self.unitWeight = abs(weight)
        self.isConsumable = isConsumable
        assert(checkRep())
    }

    // Create a quantized representation
    func createItem(quantity: Int) -> GenericItem {
        return Item(itemParameter: self, quantity: quantity)
    }

    // Global pricing information
    func getBuyValue() -> Int {
        return buyValue
    }

    func getSellValue() -> Int {
        return sellValue
    }

    func getHalfLife() -> Int? {
        return halfLife
    }

    mutating func setHalfLife(to value: Int) {
        if value < 0 {
            return
        }
        halfLife = value
        assert(checkRep())
    }

    mutating func setBuyValue(value: Int) {
        if value < 0 {
            return
        }
        buyValue = value
        assert(checkRep())
    }

    mutating func setSellValue(value: Int) {
        if value < 0 {
            return
        }
        sellValue = value
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        guard let unwrappedHalfLife = halfLife else {
            return sellValue >= 0 && buyValue >= 0
        }
        return sellValue >= 0 && buyValue >= 0 && unwrappedHalfLife >= 0 && unitWeight >= 0
    }
}

extension ItemParameter: Hashable {
    static func == (lhs: ItemParameter, rhs: ItemParameter) -> Bool {
        return lhs.itemType == rhs.itemType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.itemType)
    }
}
