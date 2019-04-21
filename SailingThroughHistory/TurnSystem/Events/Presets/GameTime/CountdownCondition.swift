//
//  CountdownTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A condition that evaluates to true if the GameTime is past the reference GameTime.
 */
class CountdownCondition: EventCondition<GameTime> {
    init(gameTime: GameVariable<GameTime>, to newValue: GameTime) {
        super.init(first: GameVariableEvaluatable(variable: gameTime),
                   second: Evaluatable(newValue), change: EqualOperator<GameTime>())
    }
}
