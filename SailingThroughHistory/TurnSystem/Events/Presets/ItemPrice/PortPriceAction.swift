//
//  PortPriceAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * Sets the price of a port by (operator) modifier.
 An example is + 1
 */
class PortPriceAction: Modify {
    private let port: Port
    private let itemParameter: ItemParameter
    private let cOperator: GenericOperator
    private let modifier: Int
    init(port: Port, itemParameter: ItemParameter, cOperator: GenericOperator,
         modifier: Int) {
        self.port = port
        self.itemParameter = itemParameter
        self.cOperator = cOperator
        self.modifier = modifier
    }
    func modify() {
        guard let result = cOperator.evaluate(first: port.getBuyValue(of: itemParameter),
                                              second: modifier) as? Int else {
                                                return
        }
        port.setBuyValue(of: itemParameter, value: result)
    }
}
