//
//  ItemType.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ItemType: GameParameter {
    let displayName: String
    let weight: Int
    private let isConsumable: Bool
    private var valuesAtPort = [Int : Port]()
    
    public init(displayName: String, weight: Int, isConsumable: Bool) {
        self.displayName = displayName
        self.weight = weight
        self.isConsumable = isConsumable
    }
    
    // Create a quantized representation
    
    func createItem(quantity: Int) -> Item {
        return Item(itemType: self, quantity: quantity)
    }
    
    // Global pricing information
    
    func getBuyValue(at port: Port) -> Int? {
        return nil
    }
    
    func getSellValue(at port: Port) -> Int? {
        return nil
    }
    
    func setBuyValue(at port: Port, value: Int) {
        
    }
    
    func setSellValue(at port: Port, value: Int) {
        
    }
    
    // Availability at ports
    
    func delete(from pot: Port) {
        
    }
}
