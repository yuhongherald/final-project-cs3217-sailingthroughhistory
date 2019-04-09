//
//  NoTaxes.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class HalfTaxesEvent { // TurnSystemEvent
    init(gameState: GenericGameState, multiplier: Int) {
        var actions: [EventAction<Int>] = []
        for port in gameState.map.getNodes() {
            guard let port = port as? Port else {
                continue
            }
            actions.append(EventAction<Int>(variable: port.taxAmount,
                                            value: BAEEvaluatable(
                                                first: VariableEvaluatable(port.taxAmount),
                                                second: Evaluable(2),
                                                evaluator: <#T##GenericOperator#>,
                                                defaultValue: <#T##_#>)))
            port.taxAmount // WHY IS NOT A GAMEVARIABLE
        }
    }
}
