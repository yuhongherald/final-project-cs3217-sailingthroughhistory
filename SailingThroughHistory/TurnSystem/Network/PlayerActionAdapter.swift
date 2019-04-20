//
//  PlayerActionAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PlayerActionAdapter {
    /// Throws if action is invalid
    /// For server actions only
    func process(state: TurnSystemNetwork.State, networkInfo: NetworkInfo,
                 data: TurnSystemState,
                 action: PlayerAction, for player: GenericPlayer) throws -> GameMessage? {
        switch state {
        case .evaluateMoves(for: let currentPlayer):
            if player != currentPlayer {
                throw PlayerActionError.wrongPhase(message: "Evaluate move on wrong player!")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Make action called on wrong phase")
        }
        switch action {
        case .move(let nodeId, let isEnd):
            return playerMove(player, nodeId, isEnd: isEnd)
        case .forceMove(let nodeId): // quick hack for updating the player's position remotely
            return playerMove(player, nodeId, isEnd: true)
        case .setTax:
            return try register(gameState: <#GenericGameState#>, portTaxAction: action, by: player)
        case .buyOrSell:
            return try handle(networkInfo: <#NetworkInfo#>, tradeAction: action, by: player)
        case .purchaseUpgrade(let upgradeType):
            if player.deviceId == networkInfo.deviceId {
                return GameMessage.playerAction(name: player.name, message: "You moved")
            }
            _ = player.buyUpgrade(upgrade: upgradeType.toUpgrade())
            return GameMessage.playerAction(name: player.name,
                                            message: " has purchased the \(upgradeType.toUpgrade().name)!")
        case .pirate:
            player.playerShip?.startPirateChase()
            return GameMessage.playerAction(name: player.name, message: " is chased by pirates!")
        case .togglePresetEvent(let eventId, let enabled):
            if player.deviceId == networkInfo.deviceId {
                return nil
            }
            guard let event = data.events[eventId] as? PresetEvent else {
                return nil
            }
            event.active = enabled
            return nil
        }
    }
    
    func handle(networkInfo: NetworkInfo, tradeAction: PlayerAction, by player: GenericPlayer) throws -> GameMessage? {
        switch tradeAction {
        case .buyOrSell(let itemParameter, let quantity):
            let message = GameMessage.playerAction(
                name: player.name,
                message: " has \(quantity > 0 ? "purchased": "sold") \(quantity) \(itemParameter.rawValue)")
            if player.deviceId == networkInfo.deviceId {
                return message
            }
            do {
                if quantity >= 0 {
                    try player.buy(itemParameter: itemParameter, quantity: quantity)
                } else {
                    try player.sell(itemParameter: itemParameter, quantity: -quantity)
                }
            } catch let error as TradeItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            return message
        default:
            return nil
        }
    }
    
    func register(gameState: GenericGameState, networkInfo: NetworkInfo,
                  portTaxAction action: PlayerAction,
                  by player: GenericPlayer) throws -> GameMessage? {
        switch action {
        case .setTax(let portId, _):
            guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                throw PlayerActionError.invalidAction(message: "Port does not exist.")
            }
            
            if networkInfo.setTaxActions[portId] != nil {
                networkInfo.setTaxActions[portId] = (action, player, false)
            } else {
                networkInfo.setTaxActions[portId] = (action, player, true)
            }
            
            return .playerAction(name: player.name, message: "Instructed \(port.name) to change tax.")
        default:
            return nil
        }
    }
    
    // TODO: Messenger, gameState
    func handleSetTax(gameState: GenericGameState, networkInfo: NetworkInfo) {
        for (action, player, success) in networkInfo.setTaxActions.values {
            switch action {
            case .setTax(let portId, let taxAmount):
                guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                    return
                }
                guard player.team == port.owner else {
                    return
                }
                guard success else {
                    self.messages.append(
                        GameMessage.playerAction(name: "",
                                                 message: "Failed to change tax for \(port.name) " +
                            "due to conflicting instructions."))
                    return
                }
                let previous = port.taxAmount.value
                port.taxAmount.value = taxAmount
                self.messages.append(GameMessage.playerAction(
                    name: player.name,
                    message: " has set the tax for \(port.name) from \(previous) to \(taxAmount)"))
            default:
                return
            }
        }
        networkInfo.setTaxActions = Dictionary()
    }
    
    func playerMove(_ player: GenericPlayer, _ nodeId: Int, isEnd: Bool) -> GameMessage? {
        guard let ship = player.playerShip else {
            return nil
        }
        let previous = ship.node.name
        player.move(nodeId: nodeId)
        
        if !isEnd {
            return nil
        }
        
        let current = ship.node.name
        return GameMessage.playerAction(name: player.name,
                                        message: " has moved from \(previous) to \(current)")
    }

}
