//
//  FreeTeaEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ItemPriceEvent: PresetEvent {
    init(gameState: GenericGameState, itemParameter: GameVariable<ItemParameter>,
         genericOperator: GenericOperator, modifier: Int) {

        let evaluatable = ItemBuyPriceEvaluatable(
            itemParameter: itemParameter,
            genericOperator: genericOperator,
            modifier: modifier)

        //TODO
        super.init(triggers: [FlipFlopTrigger()],
                   conditions: [],
                   actions: [EventAction<ItemParameter>(variable: itemParameter, value: evaluatable)],
                   parsable: { return "\(itemParameter.value.rawValue)'s price has been set to \(itemParameter.value.getBuyValue(ports: [Port]()))" },
                   displayName: "Set \(itemParameter.value.rawValue) price \(genericOperator.displayName) \(modifier)")
    }
}
