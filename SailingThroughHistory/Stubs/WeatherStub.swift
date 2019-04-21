//
//  WeatherStub.swift
//  SailingThroughHistory
//
//  Created by henry on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class WeatherStub: Weather {
    private var newWindVelocity: Float

    required init(windVelocity: Float) {
        newWindVelocity = windVelocity
        super.init()
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override func applyVelocityModifier(to oldVelocity: Float, with modifier: Float) -> Float {
        return oldVelocity + newWindVelocity
    }

    override func update(currentMonth: Int) {
    }
}
