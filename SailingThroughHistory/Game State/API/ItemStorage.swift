//
//  ItemStorage.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ItemStorage {
    func getPurchasableItemTypes() -> [ItemType]
    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int
    func buyItem(itemType: ItemType, quantity: Int) throws
    func sellItem(item: GenericItem) throws
    func sell(itemType: ItemType, quantity: Int) throws
    func removeItem(by itemType: ItemType, with quantity: Int) -> Int
}
