//
//  NoTaxes.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An event that changes all neutral port taxes by (operator) modifier.
 * An example will be + 1
 */
class TaxChangeEvent: PresetEvent {
    init(gameState: GenericGameState, genericOperator: GenericOperator, modifier: Int) {
        let modifier = max(1, modifier)
        var actions: [EventAction<Int>?] = []
        for port in gameState.map.getNodes() {
            guard let port = port as? Port, port.owner == nil else {
                continue
            }
            actions.append(EventAction<Int>(variable: port.taxAmount,
                                            value: BAEEvaluatable(
                                                first: VariableEvaluatable(port.taxAmount),
                                                second: Evaluatable(modifier),
                                                evaluator: genericOperator,
                                                defaultValue: 0)))
        }
        super.init(triggers: [FlipFlopTrigger()],
                   conditions: [],
                   actions: actions,
                   parsable: { return "Neutral port taxes have been changed" },
                   displayName: "Set neutral port taxes by \(genericOperator.displayName) \(modifier)")
    }
}
