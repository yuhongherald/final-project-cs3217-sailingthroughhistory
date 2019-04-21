//
//  FreeTeaEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An event that modifies the item's price across all ports using (operator) modifier.
 * An example will be + 1
 */
class ItemPriceEvent: PresetEvent {
    init(gameState: GenericGameState, itemParameter: GameVariable<ItemParameter>,
         genericOperator: GenericOperator, modifier: Int) {

        /*
        let evaluatable = ItemBuyPriceEvaluatable(
            itemParameter: itemParameter,
            genericOperator: genericOperator,
            modifier: modifier)
        */

        let ports = gameState.map.getNodes().map {
            $0 as? Port
        }.filter {
            $0 != nil && $0?.owner == nil
        }
        var neutralPorts = [Port]()
        var actions = [Modify]()
        for port in ports {
            guard let port = port else {
                continue
            }
            actions.append(PortPriceAction(port: port, itemParameter: itemParameter.value,
                            cOperator: genericOperator, modifier: modifier))
            neutralPorts.append(port)
        }

        super.init(triggers: [FlipFlopTrigger()],
                   conditions: [],
                   actions: actions,
                   parsable: { return
                    """
                    \(itemParameter.value.rawValue)'s price has been set to
                    \(itemParameter.value.getBuyValue(ports: neutralPorts))
                    """ },
                   displayName: "Set \(itemParameter.value.rawValue) price \(genericOperator.displayName) \(modifier)")
    }
}
