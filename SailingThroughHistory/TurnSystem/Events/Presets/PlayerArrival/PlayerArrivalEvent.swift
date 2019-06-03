//
//  PlayerArrivalEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A PresetEvent that shows a history fact when a player moves.
 */
class PlayerArrivalEvent: PresetEvent {
    init(player: GenericPlayer) {
        super.init(triggers: [EventTrigger<Int>(
            variable: player.nodeIdVariable,
            comparator: NotEqualOperator<Int>())],
            conditions: [],
            actions: [HistoryFactAction()], parsable: { return "" },
            displayName: "Arrival History Facts Event")
    }
}
