//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ItemParameter: Codable {
    let displayName: String
    let weight: Int
    public let itemType: ItemType

    private let isConsumable: Bool
    private var sellValue: Int?
    private var buyValue: Int?

    required public init(itemType: ItemType, displayName: String, weight: Int, isConsumable: Bool) {
        self.itemType = itemType
        self.displayName = displayName
        self.weight = weight
        self.isConsumable = isConsumable
    }

    // Create a quantized representation
    func createItem(quantity: Int) -> GenericItem {
        return Item(itemType: self, quantity: quantity)
    }

    // Global pricing information
    func getBuyValue() -> Int? {
        return buyValue
    }

    func getSellValue() -> Int? {
        return sellValue
    }

    func setBuyValue(value: Int) {
        buyValue = value
    }

    func setSellValue(value: Int) {
        sellValue = value
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
