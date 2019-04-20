//
//  File.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/16/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PortStub: Port {
    private var isAvailabilityHidden = false
    private var buyValueOfAllItems = 0
    private var sellValueOfAllItems = 0

    required override init(team: Team?, name: String, originX: Double, originY: Double) {
        super.init(team: nil, name: "", originX: originX, originY: originY)
        itemBuyValue.removeAll()
        itemSellValue.removeAll()
    }

    convenience init(buyValueOfAllItems: Int, sellValueOfAllItems: Int) {
        self.init(team: nil, name: "", originX: 0, originY: 0)
        isAvailabilityHidden = true
        self.buyValueOfAllItems = buyValueOfAllItems
        self.sellValueOfAllItems = sellValueOfAllItems
    }

    convenience init(buyValueOfAllItems: Int, sellValueOfAllItems: Int, itemParameters: [ItemParameter]) {
        self.init(team: nil, name: "", originX: 0, originY: 0)
        for itemParameter in itemParameters {
            setBuyValue(of: itemParameter, value: buyValueOfAllItems)
            setSellValue(of: itemParameter, value: sellValueOfAllItems)
        }
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override func getBuyValue(of type: ItemParameter) -> Int? {
        guard isAvailabilityHidden else {
            return super.getBuyValue(of: type)
        }
        return buyValueOfAllItems
    }

    override func getSellValue(of type: ItemParameter) -> Int? {
        guard isAvailabilityHidden else {
            return super.getSellValue(of: type)
        }
        return sellValueOfAllItems
    }
}
