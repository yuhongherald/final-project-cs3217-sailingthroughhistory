//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item {
    let itemType: ItemType
    let quantity: Int
    
    public init(itemType: ItemType, quantity: Int) {
        self.itemType = itemType
        self.quantity = quantity
    }
    
    func getBuyValue(at port: Port) -> Int? {
        return nil
    }
    
    func getSellValue(at port: Port) -> Int? {
        return nil
    }
}
