//
//  GenericItemStub.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GenericItemStub: GenericItem {
    let name: String
    let itemType: ItemType
    var itemParameter: ItemParameter
    var weight: Int
    var quantity: Int

    var isAvailableAtPort = true
    var doesItemDecay = true
    var buyValue = 100
    var sellValue = 100

    init(name: String, itemParameter: ItemParameter, quantity: Int) {
        self.name = name
        self.itemType = itemParameter.itemType
        self.itemParameter = itemParameter
        self.weight = itemParameter.unitWeight * quantity
        self.quantity = quantity
    }

    func setItemParameter(_ itemParameter: ItemParameter) {
    }

    func decayItem(with time: Double) -> Int? {
        if doesItemDecay {
            quantity -= 1
            return 1
        } else {
            return nil
        }
    }

    func combine(with item: GenericItem) -> Bool {
        return true
    }

    func remove(amount: Int) -> Int {
        guard quantity >= amount else {
            let deficit = amount - quantity
            quantity = 0
            return deficit
        }
        quantity -= amount
        return 0
    }

    func setQuantity(quantity: Int) {
        self.quantity = quantity
    }

    func getBuyValue(at port: Port) -> Int? {
        return buyValue
    }

    func sell(at port: Port) -> Int? {
        return sellValue
    }

    func copy() -> GenericItemStub {
        let newCopy = GenericItemStub(name: name ?? "", itemParameter: itemParameter, quantity: quantity)
        newCopy.itemParameter = itemParameter
        newCopy.weight = weight

        newCopy.isAvailableAtPort = isAvailableAtPort
        newCopy.doesItemDecay = doesItemDecay
        newCopy.buyValue = buyValue
        newCopy.sellValue = sellValue

        return newCopy
    }
}
