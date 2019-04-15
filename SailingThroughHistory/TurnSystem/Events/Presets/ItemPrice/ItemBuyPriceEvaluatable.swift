//
//  ItemPriceEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class ItemBuyPriceEvaluatable: Evaluatable<ItemParameter> {
    private let item: GameVariable<ItemParameter>
    private let genericOperator: GenericOperator
    private let modifier: Int
    override var value: ItemParameter {
        get {
            guard let newValue = genericOperator.evaluate(
                first: item.value.getBuyValue(), second: modifier) as? Int else {
                    return item.value
            }
            var copy = item.value
            copy.setBuyValue(value: newValue)
            return copy
        }
        set {
            item.value = newValue
        }
    }
    init(item: GameVariable<ItemParameter>, genericOperator: GenericOperator,
         modifier: Int) {
        self.genericOperator = genericOperator
        self.modifier = modifier
        self.item = item
        super.init(item.value)
    }
}
