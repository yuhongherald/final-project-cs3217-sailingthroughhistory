//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//
import UIKit

class Port: Node {
    public var taxAmount = 0
    public var owner: GenericPlayer?
    public var itemParametersSold = [ItemParameter]()
    
    private static let portNodeSize = CGSize(width: 50, height: 50)
    private static let portNodeImage = "port-node.png"

    init(player: GenericPlayer, pos: CGPoint) {
        owner = player
        super.init(name: player.name, image: Port.portNodeImage, frame: CGRect(origin: pos, size: Port.portNodeSize))
    }

    public func collectTax(from player: GenericPlayer) {
        // Prevent event listeners from firing unneccessarily
        if player == owner {
            return
        }
        player.money.value -= taxAmount
        owner?.money.value += taxAmount
    }
}
