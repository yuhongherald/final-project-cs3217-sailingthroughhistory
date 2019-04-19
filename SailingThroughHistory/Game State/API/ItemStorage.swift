//
//  ItemStorage.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ItemStorage {
    func getPurchasableItemParameters(ship: ShipAPI) -> [ItemParameter]
    func getMaxPurchaseAmount(ship: ShipAPI, itemParameter: ItemParameter) -> Int
    func buyItem(ship: ShipAPI, itemParameter: ItemParameter, quantity: Int) throws
    func sellItem(ship: ShipAPI, item: GenericItem) throws
    func sell(ship: ShipAPI, itemParameter: ItemParameter, quantity: Int) throws
    func removeItem(ship: ShipAPI, by itemParameter: ItemParameter, with quantity: Int) -> Int
}
