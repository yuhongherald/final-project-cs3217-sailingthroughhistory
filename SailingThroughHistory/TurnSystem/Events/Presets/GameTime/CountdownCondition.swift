//
//  CountdownTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class CountdownCondition: EventCondition<GameTime> {
    init(gameTime: GameVariable<GameTime>, to: GameTime) {
        super.init(first: GameVariableEvaluatable(variable: gameTime),
                   second: Evaluatable(to), change: EqualOperator<GameTime>())
    }
}
