//
//  RandomLoseMoneyEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class NegativeMoneyEvent: TurnSystemEvent {
    init(player: GenericPlayer) {
        player.move(nodeId: <#T##Int#>)
        player.money.value = 0
        player.clearInventory() // TODO: Change this into a variable
        super.init(triggers: [EventTrigger<Int>(variable: player.money,
                                               comparator: GreaterThanOperator<Int>())],
                   conditions: [EventCondition<Int>(
                    first: GameVariableEvaluatable<Int>(variable: player.money),
                    second: Evaluatable<Int>(0), change: LessThanOperator<Int>())],
                   actions: [],
                   displayName: "\(player.name)'s money below 0")
    }
}
