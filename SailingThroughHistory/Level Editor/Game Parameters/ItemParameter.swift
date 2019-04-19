//
//  ItemParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

struct ItemParameter: Codable {
    static let defaultPrice = 100
    let displayName: String
    let unitWeight: Int
    let itemType: ItemType
    let isConsumable: Bool

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
    func getBuyValue(ports: [Port]) -> Int {
        return ports.map({ $0.getBuyValue(of: self) }).compactMap({ $0 }).max() ?? 0
    }

    func getSellValue(ports: [Port]) -> Int {
        return ports.map({ $0.getSellValue(of: self) }).compactMap({ $0 }).min() ?? 0
    }

    func getHalfLife() -> Int? {
        return halfLife
    }

    private func checkRep() -> Bool {
        guard let unwrappedHalfLife = halfLife else {
            return unitWeight >= 0
        }
        return unwrappedHalfLife >= 0 && unitWeight >= 0
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
