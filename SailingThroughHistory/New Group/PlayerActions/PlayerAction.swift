//
//  PlayerAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum PlayerAction {
    case changeInventory(changeType: ChangeType, money: Int, items: [GenericItem])
    case roll()
    case move(to: Node)
    case forceMove(to: Node)
    case setTax(for: Port, taxAmount: Int)
    case setEvent(changeType: ChangeType, events: [ReadOnlyEventCondition])
}
