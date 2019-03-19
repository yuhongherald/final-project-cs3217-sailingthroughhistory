//
//  GenericItem.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericItem {
    var itemType: GenericItemType { get }
    var weight: Int { get }
    var quantity: Int { get set }
    
    init(itemType: GenericItemType, quantity: Int)
    func getBuyValue(at port: Port) -> Int?
    func getSellValue(at port: Port) -> Int?
}
