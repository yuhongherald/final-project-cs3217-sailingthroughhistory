//
//  GenericItemType.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericItemType: GameParameter {
    var displayName: String { get }
    var weight: Int { get }
    
    init(displayName: String, weight: Int, isConsumable: Bool)
    
    // Create a quantized representation
    func createItem(quantity: Int) -> Item
    
    // Global pricing information
    func getBuyValue(at port: Port) -> Int?
    func getSellValue(at port: Port) -> Int?
    func setBuyValue(at port: Port, value: Int)
    func setSellValue(at port: Port, value: Int)
    
    // Availability at ports
    func delete(from pot: Port)
}
