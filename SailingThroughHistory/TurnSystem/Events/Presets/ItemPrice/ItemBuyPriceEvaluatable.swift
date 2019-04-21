//
//  ItemPriceEvaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An evaluatable that creates an ItemParameter to a new price. Deprecated.
 */
class ItemBuyPriceEvaluatable: Evaluatable<ItemParameter> {
    private let itemParameter: GameVariable<ItemParameter>
    private let genericOperator: GenericOperator
    private let ports = [Port]()
    private let modifier: Int
    override var value: ItemParameter {
        get {
            guard genericOperator.evaluate(
                first: itemParameter.value.getBuyValue(ports: ports), second: modifier) as? Int != nil else {
                    return itemParameter.value
            }
            let copy = itemParameter.value
            // copy.setBuyValue(value: newValue)
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
