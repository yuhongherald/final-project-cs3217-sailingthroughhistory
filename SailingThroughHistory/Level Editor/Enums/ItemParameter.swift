//
//  ItemParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

enum ItemParameter: String, Codable, CaseIterable {
    case teaLeaves = "Tea Leaves"
    case silk = "Silk"
    case perfume = "Perfume"
    case opium = "Opium"
    case food = "Food"

    static let defaultPrice = 100

    var unitWeight: Int {
        switch self {
        case .teaLeaves:
            return 25
        case .silk:
            return 20
        case .perfume:
            return 10
        case .opium:
            return 10
        case .food:
            return 5
        }
    }

    private var halfLife: Int? {
        return nil
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

}

extension ItemParameter: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
