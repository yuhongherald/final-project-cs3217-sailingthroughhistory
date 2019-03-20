//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ItemParameter {
    private let type: ItemType
    private var sellValues = [Port: Int]()
    private var buyValues = [Port: Int]()

    init(type: ItemType) {
        self.type = type
    }

    func createItem(quantity: Int) -> Item? {
        return nil
    }

    func getBuyValue(at port: Port) -> Int? {
        return buyValues[port]
    }

    func getSellValue(at port: Port) -> Int? {
        return sellValues[port]
    }

    func setBuyValue(at port: Port, to value: Int) {
        buyValues[port] = value
    }

    func setSellValue(at port: Port, to value: Int) {
        sellValues[port] = value
    }

    func add(port: Port) {
        // TODO: unclear function usage, leave it for now
    }

    func delete(pot: Port) {
        // TODO: unclear function usage, leave it for now
    }
}

extension ItemParameter: Equatable {
    static func == (lhs: ItemParameter, rhs: ItemParameter) -> Bool {
        return lhs.type == rhs.type
    }
}
