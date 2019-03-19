//
//  ItemType.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ItemType: GenericItemType {
    let displayName: String
    let weight: Int
    private let isConsumable: Bool
    
    // Currently buy = sell value
    private var valuesAtPort = [Port : Int]()
    
    required public init(displayName: String, weight: Int, isConsumable: Bool) {
        self.displayName = displayName
        self.weight = weight
        self.isConsumable = isConsumable
    }
    
    // Create a quantized representation
    
    func createItem(quantity: Int) -> GenericItem {
        return Item(itemType: self, quantity: quantity)
    }
    
    // Global pricing information
    
    func getBuyValue(at port: Port) -> Int? {
        return valuesAtPort[port]
    }
    
    func getSellValue(at port: Port) -> Int? {
        return valuesAtPort[port]
    }
    
    func setBuyValue(at port: Port, value: Int) {
        if getBuyValue(at: port) == nil {
            port.itemTypes.append(self)
        }
        valuesAtPort[port] = value
    }
    
    func setSellValue(at port: Port, value: Int) {
        valuesAtPort[port] = value
    }
    
    // Availability at ports
    
    func delete(from port: Port) {
        guard let index = port.itemTypes.firstIndex(where: { $0 == self }) else {
            return
        }
        port.itemTypes.remove(at: index)
        valuesAtPort.removeValue(forKey: port)
    }
}
