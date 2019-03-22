//
//  DiceFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class DiceFactory {
    let randomizer: Randomable

    init(randomizer: Randomable) {
        self.randomizer = randomizer
    }

    func createDice(lower: Int, upper: Int) -> Dice {
        return Dice(lower: lower, upper: upper, randomizer: randomizer)
    }
}
