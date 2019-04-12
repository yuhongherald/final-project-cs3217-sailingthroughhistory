//
//  PirateEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PirateEvent: UniqueTurnSystemEvent {
    init(player: GenericPlayer) {
        super.init(triggers: [EventTrigger<Int>(
            variable: player.playerShip.nodeIdVariable,
            comparator: NotEqualOperator<Int>())],
            conditions: [],
            actions: [PirateAction()], parsable: { return "\(player.name) is being chased by pirates!" },
            displayName: "Pirate event")
    }
}
