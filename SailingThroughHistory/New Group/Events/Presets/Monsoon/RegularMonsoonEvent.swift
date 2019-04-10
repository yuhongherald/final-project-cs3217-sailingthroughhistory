//
//  RegularMonsoonEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/*
class RegularMonsoonEvent: TurnSystemEvent {
    init(gameState: GenericGameState, start: Int, end: Int, speed: Int) {
        var actions: [EventAction<Bool>] = []
        for path in gameState.map.getAllPaths() {
            for monsoon in path.modifiers {
                guard let monsoon = monsoon as? VolatileMonsoon else {
                    continue
                }
                actions.append(EventAction(variable: monsoon.isActiveVariable, value: Evaluatable(false)))
            }
        }
        super.init(triggers: [MonthWithinTrigger(gameTime: gameState.gameTime,
                                                 start: start, end: end)],
                   conditions: [],
                   actions: actions,
                   displayName: "No monsoon!")
    }
}
*/
