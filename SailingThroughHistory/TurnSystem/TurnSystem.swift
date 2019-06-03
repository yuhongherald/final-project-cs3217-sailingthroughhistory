//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * The default implementation of GenericTurnSystem.
 */
class TurnSystem: GenericTurnSystem {

    var eventPresets: EventPresets?
    var messages: [GameMessage] {
        get {
            return data.messages
        }
        set {
            data.messages = newValue
        }
    }
    var gameState: GenericGameState {
        return data.gameState
    }

    let network: GenericTurnSystemNetwork
    let data: GenericTurnSystemState
    let playerInputController: GenericPlayerInputController

    init(network: GenericTurnSystemNetwork,
         playerInputControllerFactory: GenericPlayerInputControllerFactory) {
        self.data = network.data
        self.network = network
        self.playerInputController = playerInputControllerFactory.create(
            network: network, data: self.data)
        self.eventPresets = EventPresets(gameState: self.data.gameState, turnSystem: self)

        if let eventPresets = self.eventPresets {
            _ = self.data.addEvents(events: eventPresets.getEvents())
        }
    }

    func getPresetEvents() -> [PresetEvent] {
        return data.getPresetEvents()
    }

    func startGame() {
        guard let player = network.getFirstPlayer() else {
            network.state = .waitForTurnFinish
            network.waitForTurnFinish()
            return
        }
        network.state = .waitPlayerInput(from: player)
    }

    // for testing
    func getState() -> TurnSystemNetwork.State {
        return network.state
    }

    // MARK: - Player actions
    func roll(for player: GenericPlayer) throws -> (Int, [Int]) {
        try playerInputController.checkInputAllowed(from: player)

        if player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has already rolled!")
        }
        return player.roll()
    }

    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws {
        try playerInputController.checkInputAllowed(from: player)
        if !player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has not rolled!")
        }

        if !player.roll().1.contains(nodeId) {
            throw PlayerActionError.invalidAction(message: "Node is out of range!")
        }

        if nodeId == player.node?.identifier {
            return
        }

        var path = player.getPath(to: nodeId)
        path.removeFirst()
        for (index, transitNode) in path.enumerated() {
            network.pendingActions.append(.move(toNodeId: transitNode, isEnd: index == path.indices.last))
        }

        if isSuccess(probability: player.getPirateEncounterChance(at: nodeId)) {
            network.pendingActions.append(.pirate)
        }
    }

    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws {
        try playerInputController.checkInputAllowed(from: player)
        guard let port = gameState.map.nodeIDPair[portId] as? Port else {
            throw PlayerActionError.invalidAction(message: "Port does not exist")
        }
        guard player.team == port.owner else {
            throw PlayerActionError.invalidAction(message: "Player does not own port!")
        }
        if amount > GameConstants.maxTax {
            throw PlayerActionError.invalidAction(message: "Tax cannot be over \(GameConstants.maxTax)")
        }
        if amount < 0 {
            throw PlayerActionError.invalidAction(message: "Tax cannot be negative")
        }

        network.pendingActions.append(.setTax(forPortId: portId, taxAmount: amount))
    }

    func buy(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        try playerInputController.checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Bought quantity must be more than 0.")
        }
        if quantity >= 0 {
            try player.buy(itemParameter: itemParameter, quantity: quantity)
            network.pendingActions.append(.buyOrSell(itemParameter: itemParameter, quantity: quantity))
        }
    }

    func sell(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        try playerInputController.checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Sold quantity must be more than 0.")
        }
        if quantity >= 0 {
            do {
                try player.sell(itemParameter: itemParameter, quantity: quantity)
            } catch let error as TradeItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            network.pendingActions.append(.buyOrSell(itemParameter: itemParameter, quantity: -quantity))
        }
    }

    func toggle(eventId: Int, enabled: Bool, by player: GenericPlayer) throws {
        guard let event = data.events[eventId] as? PresetEvent else {
            throw PlayerActionError.invalidAction(message: "Event does not exist")
        }
        try playerInputController.checkInputAllowed(from: player)
        if !player.isGameMaster {
            throw PlayerActionError.invalidAction(message: "You are not a game master.")
        }
        event.active = enabled
        network.pendingActions.append(.togglePresetEvent(eventId: eventId, enabled: enabled))
    }

    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage? {
        try playerInputController.checkInputAllowed(from: player)
        if !player.canBuyUpgrade() {
            throw PlayerActionError.invalidAction(message: "Not allowed to buy upgrades now.")
        }
        let (success, msg) = player.buyUpgrade(upgrade: upgrade)
        if success {
            network.pendingActions.append(.purchaseUpgrade(type: upgrade.type))
        }
        return msg
    }

    func subscribeToState(with callback: @escaping (TurnSystemNetwork.State) -> Void) {
        network.stateVariable.subscribe(with: callback)
    }

    func acknowledgeTurnStart() {
        guard let player = network.currentPlayer else {
            return
        }
        playerInputController.startPlayerInput(from: player)
    }

    func endTurn() {
        network.endTurn()
    }

    // unused functionality setevents
    private func setEvents(changeType: ChangeType, events: [TurnSystemEvent]) -> Bool {
        switch changeType {
        case .add:
            return data.addEvents(events: events)
        case .remove:
            return data.removeEvents(events: events)
        case .set:
            return data.setEvents(events: events)
        }
    }

    private func isSuccess(probability: Double) -> Bool {
        return Double(arc4random()) / Double(UINT32_MAX) < probability
    }
}