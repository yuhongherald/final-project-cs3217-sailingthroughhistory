//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Item: GenericItem {
    public let itemType: GenericItemType
    public var weight: Int {
        get {
            return quantity * itemType.weight
        }
    }
    internal var quantity: Int
    
    public required init(itemType: GenericItemType, quantity: Int) {
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
