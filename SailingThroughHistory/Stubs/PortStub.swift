//
//  File.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/16/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PortStub: Port {
    private var buyValueOfAllItems = 0
    private var sellValueOfAllItems = 0

    required override init(team: Team?, name: String, originX: Double, originY: Double) {
        super.init(team: nil, name: "", originX: 0, originY: 0)
    }

    convenience init(buyValueOfAllItems: Int, sellValueOfAllItems: Int) {
        self.init(team: nil, name: "", originX: 0, originY: 0)
        self.buyValueOfAllItems = buyValueOfAllItems
        self.sellValueOfAllItems = sellValueOfAllItems
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override func getBuyValue(of type: ItemParameter) -> Int? {
        return buyValueOfAllItems
    }

    override func getSellValue(of type: ItemParameter) -> Int? {
        return sellValueOfAllItems
    }
}
