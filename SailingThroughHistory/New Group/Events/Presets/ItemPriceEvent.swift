//
//  FreeTeaEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ItemPriceEvent: TurnSystemEvent {
    init(gameState: GenericGameState, itemType: ItemType,
         genericOperator: GenericOperator, modifier: Int) {
        let item = gameState.itemParameters.first {
            $0.itemType == itemType
        }
        // WIP
        super.init(triggers: [], conditions: [], actions: [], displayName:
        "Set \(itemType.rawValue) price \(genericOperator.displayName) \(modifier)")
    }
}
