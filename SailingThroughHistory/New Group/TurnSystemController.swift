//
//  TurnSystemController.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystemController {
    /*
    func roll(for player: GenericPlayer) throws -> (Int, [Int]) {
        try checkInputAllowed(from: player)
        
        if player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has already rolled!")
        }
        return player.roll()
    }
    
    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        if !player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has not rolled!")
        }
        
        if !player.roll().1.contains(nodeId) {
            throw PlayerActionError.invalidAction(message: "Node is out of range!")
        }
        var path = player.getPath(to: nodeId)
        path.removeFirst()
        for transitNode in path {
            pendingActions.append(.move(toNodeId: transitNode))
        }
        pendingActions.append(.move(toNodeId: nodeId))
    }
    
    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard let port = gameState.map.nodeIDPair[portId] as? Port else {
            throw PlayerActionError.invalidAction(message: "Port does not exist")
        }
        guard player.team == port.owner else {
            throw PlayerActionError.invalidAction(message: "Player does not own port!")
        }
        
        pendingActions.append(.setTax(forPortId: portId, taxAmount: amount))
    }
    
    func buy(itemType: ItemType, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Bought quantity must be more than 0.")
        }
        if quantity >= 0 {
            try player.buy(itemType: itemType, quantity: quantity)
            pendingActions.append(.buyOrSell(itemType: itemType, quantity: quantity))
        }
    }
    
    func sell(itemType: ItemType, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Sold quantity must be more than 0.")
        }
        if quantity >= 0 {
            do {
                try player.sell(itemType: itemType, quantity: quantity)
            } catch let error as BuyItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            pendingActions.append(.buyOrSell(itemType: itemType, quantity: -quantity))
        }
    }
    */
}
