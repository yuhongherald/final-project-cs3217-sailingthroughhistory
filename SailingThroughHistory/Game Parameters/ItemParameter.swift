//
//  ItemParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * Enums to store item types, default prices and unit weights.
 */
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

    // Create a quantized representation
    func createItem(quantity: Int) -> GenericItem {
        return Item(itemParameter: self, quantity: quantity)
    }

    // Global pricing information
    /// Get maximum buy values among all ports.
    func getBuyValue(ports: [Port]) -> Int {
        return ports.map({ $0.getBuyValue(of: self) }).compactMap({ $0 }).max() ?? 0
    }

    /// Get minimum sell values among all ports.
    func getSellValue(ports: [Port]) -> Int {
        return ports.map({ $0.getSellValue(of: self) }).compactMap({ $0 }).min() ?? 0
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try ItemParameter(rawValue: container.decode(String.self, forKey: .type))
        guard let unwrappedDecoded = decoded else {
            fatalError("Unknown Item")
        }
        self = unwrappedDecoded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rawValue, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension ItemParameter: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
