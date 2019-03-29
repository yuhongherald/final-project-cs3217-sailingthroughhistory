//
//  Consumable.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Consumable: Item, GenericConsumable {

    /// If Consumable quantity is enough, decrease quantity by amount. Return 0.
    /// If Consumable quantity is not enough, decrease quantity to 0. Return deficeit.
    /// - Returns:
    ///   If Consumable quantity is enough, return 0.
    ///   If Consumable quantity is not enough, return deficeit as positive integer.
    func consume(amount: Int) -> Int {
        if quantity < amount {
            let deficeit = amount - quantity
            quantity = 0
            return deficeit
        }
        quantity -= amount
        return 0
    }
}
