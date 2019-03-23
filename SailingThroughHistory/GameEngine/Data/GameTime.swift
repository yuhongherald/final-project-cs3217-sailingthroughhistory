//
//  GameTime.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct GameTime {
    let baseYear: Int
    // 1-based index
    var week: Int {
        return Int(actualWeeks) % 4
    }
    var month: Int {
        return (Int(actualWeeks) / 4) % 12
    }
    var year: Int {
        return Int(actualWeeks) / 48
    }

    private var actualWeeks = 0.0

    init(baseYear: Int) {
        self.baseYear = baseYear
    }

    mutating func reset() {
        actualWeeks = 0
    }

    mutating func addWeeks(_ weeks: Double) {
        actualWeeks += weeks
    }

}
