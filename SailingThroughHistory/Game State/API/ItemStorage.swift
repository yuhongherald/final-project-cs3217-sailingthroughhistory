//
//  ItemStorage.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ItemStorage {
    func getPurchasableItemParameters() -> [ItemParameter]
    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int
    func buyItem(itemParameter: ItemParameter, quantity: Int) throws
    func sellItem(item: GenericItem) throws
    func sell(itemParameter: ItemParameter, quantity: Int) throws
    func removeItem(by itemParameter: ItemParameter, with quantity: Int) -> Int
}
