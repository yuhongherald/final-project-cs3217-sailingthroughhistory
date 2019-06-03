//
//  GenericItem.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * Protocol for items' attributes.
 */
protocol GenericItem: Codable {
    /// Display name of the item
    var name: String { get }
    /// ItemParameter of the item, i.e. buy/sell value, unit weight
    var itemParameter: ItemParameter { get }
    /// Total weight of the item
    var weight: Int { get }
    /// Quantity of the item
    var quantity: Int { get set }

    /// Combine quantities of items with the same ItemParameter
    func combine(with item: inout GenericItem) -> Bool
    /// Decrease the quantity of the item by amount
    func remove(amount: Int) -> Int
    /// Get export price of the item at the port
    func getBuyValue(at port: Port) -> Int?
    /// Get import price of the item at the port
    func sell(at port: Port) -> Int?
}

func == (lhs: GenericItem, rhs: GenericItem?) -> Bool {
    return lhs.itemParameter == rhs?.itemParameter && lhs.quantity == rhs?.quantity
}
