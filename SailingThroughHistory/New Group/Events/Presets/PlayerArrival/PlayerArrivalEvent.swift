//
//  PlayerArrivalEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PlayerArrivalEvent: PresetEvent {
    init(player: GenericPlayer, turnSystem: GenericTurnSystem) {
        super.init(triggers: [EventTrigger<Int>(
            variable: player.nodeIdVariable,
            comparator: NotEqualOperator<Int>())],
            conditions: [],
            actions: [PirateAction(player: player, turnSystem: turnSystem), HistoryFactAction()], parsable: { return "\(player.name) is being chased by pirates!" },
            displayName: "Pirate event")
    }
}
