//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Port: Node {
    public var taxAmount = 0
    public var owner: Player?
    
    public func collectTax(from player: Player) {
        // Prevent event listeners from firing unneccessarily
        if owner == player {
            return
        }
        player.money.value -= taxAmount
        owner?.money.value += taxAmount
    }
}
