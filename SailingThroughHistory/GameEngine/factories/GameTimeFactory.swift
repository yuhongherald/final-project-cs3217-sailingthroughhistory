//
//  GameTime.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameTimeFactory {
    let secondsToWeeks: Double

    init(secondsToWeeks: Double) {
        self.secondsToWeeks = secondsToWeeks
    }

    func createTime(baseYear: Int) -> GameTime {
        return GameTime(secondsToWeeks: secondsToWeeks, baseYear: baseYear)
    }
}
