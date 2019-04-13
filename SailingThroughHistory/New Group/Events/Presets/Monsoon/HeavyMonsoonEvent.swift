//
//  HeavyMonsoonEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class HeavyMonsoonEvent: PresetEvent {
    init(gameState: GenericGameState, start: Int, end: Int) {
        var actions: [EventAction<Bool>?] = []
        for path in gameState.map.getAllPaths() {
            for monsoon in path.modifiers {
                guard let monsoon = monsoon as? VolatileMonsoon else {
                    continue
                }
                actions.append(EventAction<Bool>(
                    variable: monsoon.isActiveVariable,
                    value: ConditionEvaluatable<Bool>(
                        trueValue: Evaluatable<Bool>(true),
                        falseValue: Evaluatable<Bool>(false),
                        conditions: [MonthWithinCondition(gameTime: gameState.gameTime,
                            start: start, end: end)])))
            }
        }
        // [MonthWithinTrigger(gameTime: gameState.gameTime,
        // start: start, end: end)]
        super.init(triggers: [EventTrigger<GameTime>(variable: gameState.gameTime,
                                                     comparator: NotEqualOperator<Int>())],
                   conditions: [],
                   actions: actions,
                   parsable: { return "Heavy monsoon!" },
                   displayName: "Heavy monsoon!")
    }
}
