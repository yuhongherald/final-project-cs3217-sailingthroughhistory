//
//  FreeTeaEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ItemPriceEvent: PresetEvent {
    init(gameState: GenericGameState, itemType: ItemType,
         genericOperator: GenericOperator, modifier: Int) {
        let rawItem = gameState.itemParameters.first {
            $0.value.itemType == itemType
        }
        guard let item = rawItem else {
            fatalError("Item not found in item parameters during runtime")
        }

        let evaluatable = ItemBuyPriceEvaluatable(
            item: item,
            genericOperator: genericOperator,
            modifier: modifier)

        super.init(triggers: [FlipFlopTrigger()],
                   conditions: [],
                   actions: [EventAction<ItemParameter>(variable: item, value: evaluatable)],
                   displayName: "Set \(itemType.rawValue) price \(genericOperator.displayName) \(modifier)")
    }
}
