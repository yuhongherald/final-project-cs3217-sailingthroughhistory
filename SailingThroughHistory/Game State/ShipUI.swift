//
//  ShipUI.swift
//  SailingThroughHistory
//
//  Created by henry on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ShipUI: GameObject {
    private let shipWidth: Double = 50

    init(ship: Ship) {
        guard let frame = Rect(originX: 0, originY: 0, height: shipWidth, width: shipWidth) else {
            fatalError("shipWidth is invalid.")
        }
        super.init(frame: frame)
        ship.subscribeToLocation(with: moveShip)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    private func moveShip(to node: Node) {
        let newX = node.frame.originX
        let newY = node.frame.originY
        guard let frame = Rect(originX: newX, originY: newY, height: shipWidth, width: shipWidth) else {
            fatalError("New frame is invalid")
        }

        self.frame.value = frame
    }

}
