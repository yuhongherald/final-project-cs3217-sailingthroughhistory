//
//  RandomLoseMoneyEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Used to create player death event when money goes below zero.
/// Sets money to 0, player's position to home node and empties player inventory.
/// Note player gets to keep ship upgrades.
class NegativeMoneyEvent: PresetEvent {
    init(player: GenericPlayer) {
        var actions: [Modify?] = []
        actions.append(EventAction<Int>(variable: player.money,
                                        value: Evaluatable<Int>(0)))
        actions.append(EventAction<[GenericItem]>(variable: player.playerShip?.items,
                                                  value: Evaluatable<[GenericItem]>([])))
        actions.append(EventAction<Int>(variable: player.playerShip?.nodeIdVariable,
                                        value: Evaluatable<Int>(player.homeNode)))
        super.init(triggers: [EventTrigger<Int>(variable: player.money,
                                               comparator: GreaterThanOperator<Int>())],
                   conditions: [EventCondition<Int>(
                    first: GameVariableEvaluatable<Int>(variable: player.money),
                    second: Evaluatable<Int>(0), change: LessThanOperator<Int>())],
                   actions: actions,
                   parsable: { return "\(player.name) has lost their ship's"
                    + "cargo and is sent back to \(player.homeNode)" },
                   displayName: "\(player.name)'s money below 0")
    }
}
