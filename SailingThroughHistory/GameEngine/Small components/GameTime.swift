//
//  GameTime.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct GameTime {
    let secondsToWeeks: Double
    let baseYear: Int
    private var seconds: Double = 0
    // 1-based index
    var week: Int {
        get {
            return 0
        }
        set {
        }
    }
    var month: Int {
        get {
            return 0
        }
        set {
        }
    }
    var year: Int {
        get {
            return 0
        }
        set {
            
        }
    }

    init(secondsToWeeks: Double, baseYear: Int) {
        self.secondsToWeeks = secondsToWeeks
        self.baseYear = baseYear
    }

    mutating func reset() {
        seconds = 0
    }

    mutating func addSeconds(_ seconds: Double) {
        self.seconds += seconds
    }

    // no clamping is done
    mutating func addGameTime(weeks: Int, months: Int, years: Int) {
        self.seconds += ((Double(years) / Double(GameConstants.monthsInYear) +
                        Double(months)) / Double(GameConstants.weeksInMonth) +
                        Double(weeks)) / secondsToWeeks
    }
}
