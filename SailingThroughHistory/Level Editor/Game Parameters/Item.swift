//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item {
    var type: ItemParameter!
    var quantity: Int!

    init(_ type: ItemType, quantity: Int) {
        self.type = type
        self.quantity = quantity
    }

    func getRemainingQuantity(port: Port) -> Int {
        return quantity
    }
}
