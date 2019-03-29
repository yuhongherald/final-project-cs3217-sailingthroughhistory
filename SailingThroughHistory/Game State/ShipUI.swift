//
//  ShipUI.swift
//  SailingThroughHistory
//
//  Created by henry on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ShipUI: GameObject {

    private let shipImagePath = "ship.png"
    private let shipWidth: Double = 50

    init(ship: Ship) {
        guard let frame = Rect(originX: 0, originY: 0, height: shipWidth, width: shipWidth) else {
            fatalError("shipWidth is invalid.")
        }
        super.init(image: shipImagePath, frame: frame)
        ship.location.subscribe(with: moveShip)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    private func moveShip(to location: Location) {
        let start = location.start
        let end = location.end
        let fraction = Double(location.fractionToEnd)
        var newX = start.frame.midX
        newX *= fraction
        newX += end.frame.midX * (1 - fraction)
        newX -= shipWidth / 2
        var newY = start.frame.midY
        newY *= fraction
        newY += end.frame.midY * (1 - fraction)
        newY -= shipWidth / 2
        guard let frame = Rect(originX: newX, originY: newY, height: shipWidth, width: shipWidth) else {
            fatalError("New frame is invalid")
        }

        self.frame.value = frame
    }

}
