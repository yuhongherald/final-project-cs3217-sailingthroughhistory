//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Port: Node {
    public var taxAmount = 0
    public var owner: GenericPlayer?
    public var itemTypes = [GenericItemType]()

    public func collectTax(from player: GenericPlayer) {
        // Prevent event listeners from firing unneccessarily
        if player == owner {
            return
        }
        player.money.value -= taxAmount
        owner?.money.value += taxAmount
    }

}
