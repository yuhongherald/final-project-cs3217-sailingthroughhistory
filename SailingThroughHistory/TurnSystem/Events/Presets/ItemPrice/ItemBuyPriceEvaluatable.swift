//
//  ItemPriceEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ItemBuyPriceEvaluatable: Evaluatable<ItemParameter> {
    private let itemParameter: GameVariable<ItemParameter>
    private let genericOperator: GenericOperator
    //TODO
    private let ports = [Port]()
    private let modifier: Int
    override var value: ItemParameter {
        get {
            guard let newValue = genericOperator.evaluate(
                first: itemParameter.value.getBuyValue(ports: ports), second: modifier) as? Int else {
                    return itemParameter.value
            }
            var copy = itemParameter.value
            //copy.setBuyValue(value: newValue)
            return copy
        }
        set {
            itemParameter.value = newValue
        }
    }
    init(itemParameter: GameVariable<ItemParameter>, genericOperator: GenericOperator,
         modifier: Int) {
        self.genericOperator = genericOperator
        self.modifier = modifier
        self.itemParameter = itemParameter
        super.init(itemParameter.value)
    }
}
