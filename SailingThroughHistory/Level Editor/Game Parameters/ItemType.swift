//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ItemType: GameParameter {
    func createItem(quantity: Int) -> Item
    func getBuyValue(at port: Port) -> Int?
    func getSellValue(at port: Port) -> Int?
    func setBuyValue(at port: Port)
    func setSellValue(at port: Port)
    func add(port: Port)
    func delete(pot: Port)
}
