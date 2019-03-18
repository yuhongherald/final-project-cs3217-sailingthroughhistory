//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ItemType: GameParameter {
    var displayName: Int { get }
    var weight: Int { get }
    var isConsumable: Bool { get }
    
    // Create a quantized representation
    func createItem(quantity: Int) -> Item
    
    // Global pricing information
    func getBuyValue(at port: Port) -> Int?
    func getSellValue(at port: Port) -> Int?
    func setBuyValue(at port: Port)
    func setSellValue(at port: Port)
    
    // Availability at ports
    func add(to port: Port)
    func delete(from pot: Port)
}
