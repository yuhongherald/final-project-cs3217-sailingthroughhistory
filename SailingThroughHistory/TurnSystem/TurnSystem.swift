//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TurnSystem: GenericTurnSystem {

    var eventPresets: EventPresets?
    var messages: [GameMessage] {
        get {
            return messenger.messages
        }
        set {
            messenger.messages = newValue
        }
    }

    private let network: TurnSystemNetwork
    private let messenger: GameMessenger
    private let data: GenericTurnSystemState
    var gameState: GenericGameState {
        return data.gameState
    }

    init(network: TurnSystemNetwork, startingState: GenericTurnSystemState,
         messenger: GameMessenger) {
        self.data = startingState
        self.network = network
        self.messenger = messenger
        self.eventPresets = EventPresets(gameState: startingState.gameState, turnSystem: self)

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
        try checkInputAllowed(from: player)
        guard let port = gameState.map.nodeIDPair[portId] as? Port else {
            throw PlayerActionError.invalidAction(message: "Port does not exist")
        }
        guard player.team == port.owner else {
            throw PlayerActionError.invalidAction(message: "Player does not own port!")
        }

        network.pendingActions.append(.setTax(forPortId: portId, taxAmount: amount))
    }

    func buy(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Bought quantity must be more than 0.")
        }
        if quantity >= 0 {
            try player.buy(itemParameter: itemParameter, quantity: quantity)
            network.pendingActions.append(.buyOrSell(itemParameter: itemParameter, quantity: quantity))
        }
    }

    func sell(itemParameter: ItemParameter, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
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
        try checkInputAllowed(from: player)
        if !player.isGameMaster {
            throw PlayerActionError.invalidAction(message: "You are not a game master.")
        }
        event.active = enabled
        network.pendingActions.append(.togglePresetEvent(eventId: eventId, enabled: enabled))
    }

    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage? {
        try checkInputAllowed(from: player)
        if !player.canBuyUpgrade() {
            throw PlayerActionError.invalidAction(message: "Not allowed to buy upgrades now.")
        }
        let (success, msg) = player.buyUpgrade(upgrade: upgrade)
        if success {
            network.pendingActions.append(.purchaseUpgrade(type: upgrade.type))
        }
        return msg
    }

    private func checkInputAllowed(from player: GenericPlayer) throws {
        switch network.state {
        case .playerInput(let curPlayer, _):
            if player != curPlayer {
                throw PlayerActionError.wrongPhase(message: "Please wait for your turn")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Action called on wrong phase")
        }
    }

    func subscribeToState(with callback: @escaping (TurnSystemNetwork.State) -> Void) {
        network.stateVariable.subscribe(with: callback)
    }

    func acknowledgeTurnStart() {
        guard let player = network.currentPlayer else {
            return
        }
        startPlayerInput(from: player)
    }

    func endTurn() {
        network.endTurn()
    }

    // unused functionality
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

    private func startPlayerInput(from player: GenericPlayer) {
        let endTime = Date().timeIntervalSince1970 + GameConstants.playerTurnDuration
        let turnNum = data.currentTurn
        DispatchQueue.global().asyncAfter(deadline: .now() + GameConstants.playerTurnDuration) { [weak self] in
            if player == self?.network.currentPlayer && self?.data.currentTurn == turnNum {
                self?.network.endTurn()
            }
        }

        self.network.state = .playerInput(from: player, endTime: endTime)
    }
}
