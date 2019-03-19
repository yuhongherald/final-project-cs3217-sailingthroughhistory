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
    func combine(with item: GenericItem) -> Bool
    func setQuantity(quantity: Int)
    func getBuyValue(at port: Port) -> Int?
    func sell(at port: Port) -> Int?
}

func == (lhs: GenericItem, rhs: GenericItem?) -> Bool {
    return lhs.itemType == rhs?.itemType && lhs.quantity == rhs?.quantity
}
