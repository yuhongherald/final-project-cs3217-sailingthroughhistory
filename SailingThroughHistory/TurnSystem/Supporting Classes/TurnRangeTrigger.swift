//
//  TurnRangeTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class MonthChangeTrigger: EventTrigger<GameTime> {
    init(gameState: GenericGameState, monthStart: Int, monthEnd: Int) {
        super.init(variable: gameState.gameTime,
                   comparator: GameTimeWithin(start: monthStart, end: monthEnd))
    }
}
