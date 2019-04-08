//
//  TurnRangeTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnRangeTrigger: EventTrigger<Any> {
    init(gameState: GenericGameState, monthStart: Int, monthEnd: Int) {
        
        if monthStart < monthEnd {
            // wrap, so 2 variables
        } else {
            
        }
        super.init(variable: <#T##GameVariable<Any>#>, comparator: <#T##GenericComparator#>)
    }

}
