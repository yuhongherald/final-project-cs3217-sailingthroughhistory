//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystem {
    /// Returns false if action is invalid
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> Bool {
        //player.
        switch action {
        case .changeInventory(changeType: let changeType, money: let money, items: let items):
            break
        case .roll:
            break
        case .move(to: let node):
            break
        case .forceMove(to: let node): // quick hack for updating the player's position remotely
            break
        case .setTax(for: let port, let taxAmount):
            guard player == port.owner else { // TODO: Fix equality assumption
                return false
            }
        port.taxAmount = taxAmount
        return true
            //case .setEvent(changeType: ChangeType, events: [GameEvent]
        }
        return false
    }
}
