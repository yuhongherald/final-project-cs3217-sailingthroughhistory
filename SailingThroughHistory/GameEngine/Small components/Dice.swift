//
//  Dice.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Dice {
    let lower: Int
    let upper: Int
    private let randomizer: Randomable

    init(lower: Int, upper: Int, randomizer: Randomable) {
        self.lower = lower
        self.upper = upper
        self.randomizer = randomizer
    }

    func roll() -> Int {
        return lower + Int(randomizer.random() * Double(upper - lower))
    }
}
