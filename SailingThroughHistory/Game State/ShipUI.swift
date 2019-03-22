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
    }

}
