//
//  TurnRangeTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class MonthChangeTrigger: EventTrigger<GameTime> {
    init(gameTime: GameVariable<GameTime>, start: Int, end: Int) {
        super.init(variable: gameTime,
                   comparator: MonthWithin(start: start, end: end))
    }
}
