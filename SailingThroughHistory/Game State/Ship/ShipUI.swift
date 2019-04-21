//
//  ShipUI.swift
//  SailingThroughHistory
//
//  Created by henry on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// UI Representation of a ship in the game.
import UIKit

class ShipUI: GameObject {
    private let shipWidth: Double = 50
    private(set) weak var ship: Ship?

    init(ship: Ship) {
        self.ship = ship
        let frame = Rect(originX: 0, originY: 0, height: shipWidth, width: shipWidth)
        super.init(frame: frame)
        ship.subscribeToLocation(with: moveShip)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    private func moveShip(to node: Node) {
        let newX = node.frame.originX
        let newY = node.frame.originY
        let frame = Rect(originX: newX, originY: newY, height: shipWidth, width: shipWidth)

        self.frame.value = frame
    }

}
