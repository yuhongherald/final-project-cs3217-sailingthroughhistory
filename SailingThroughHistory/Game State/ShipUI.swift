//
//  ShipUI.swift
//  SailingThroughHistory
//
//  Created by henry on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ShipUI: GameObject {

    private let shipImagePath = "ship.png"
    private let shipWidth = 50

    init(ship: Ship) {
        let frame = CGRect(x: 0, y: 0, width: shipWidth, height: shipWidth)
        super.init(image: shipImagePath, frame: frame)
        ship.location.subscribe(with: updateShip)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    private func updateShip(event: Event<Location>) {
        guard let location = event.element else {
            return
        }
        let start = location.start
        let end = location.end
        let fraction = location.fractionToEnd
        let newX = start.frame.midX * CGFloat(fraction) + end.frame.midX * CGFloat(1 - fraction) - CGFloat(shipWidth) / 2
        let newY = start.frame.midY * CGFloat(fraction) + end.frame.midY * CGFloat(1 - fraction) - CGFloat(shipWidth) / 2
        frame = CGRect(x: newX, y: newY, width: CGFloat(shipWidth), height: CGFloat(shipWidth))
    }

}
