//
//  Consumable.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Consumable: Item, GenericConsumable {
    
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
