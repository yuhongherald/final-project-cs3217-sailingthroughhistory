//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystem: GenericTurnSystem {
    
    enum State {
        case ready
        case waitForTurnFinish
        case waitForStateUpdate
        case invalid
    }

    private var callbacks: [() -> Void] = []
    private var state: State
    private let network: RoomConnection
    private var isBlocking = false
    private let isMaster: Bool
    var data: GenericTurnSystemState
    private let deviceId: String
    var gameState: GenericGameState {
        return data.gameState
    }
    private var _currentPlayer: GenericPlayer?
    var currentPlayer: GenericPlayer? {
        return _currentPlayer
    }

    init(isMaster: Bool, network: RoomConnection, startingState: GameState, deviceId: String) {
        self.deviceId = deviceId
        self.network = network
        self.isMaster = isMaster
        self.data = TurnSystemState(gameState: startingState, joinOnTurn: 0) // TODO: Turn harcoded
        self.state = .invalid
        state = .ready
    }

    // TODO: Add to protocol and also do a running gamestate
    func startGame() {
        state = .waitForTurnFinish
        _currentPlayer = getNextPlayer()
    }

    // for testing
    func getState() -> TurnSystem.State {
        return state
    }

    /// Returns false if action is invalid
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> PlayerActionError? {
        switch state {
        case .waitForTurnFinish:
            break
        default:
            return PlayerActionError.wrongPhase(message: "Make action called on wrong phase")
        }
        switch action {
        case .changeInventory(changeType: let changeType, money: let money, items: let items):
            return PlayerActionError.invalidAction(message: "Deprecated action! Use buyOrSell")
        case .roll:
            if player.hasRolled {
                return PlayerActionError.invalidAction(message: "Player has already rolled!")
            }
            _ = player.roll()
        case .move(to: let node):
            if !player.hasRolled {
                return PlayerActionError.invalidAction(message: "Player has not rolled!")
            }
            if !player.getNodesInRange(roll: player.roll()).contains(node) {
                return PlayerActionError.invalidAction(message: "Node is out of range!")
            }
            player.move(node: node)
        case .forceMove(to: let node): // quick hack for updating the player's position remotely
            player.move(node: node)
        // some stuff with a sequence
        // for node in nodes (Doesn't check adjacency)
        // player.move(node: node)
        case .setTax(for: let port, let taxAmount):
            guard player == port.owner else { // TODO: Fix equality assumption
                return PlayerActionError.invalidAction(message: "Player does not own port!")
            }
        port.taxAmount = taxAmount
        case .setEvent(changeType: let changeType, events: let events):
            guard setEvents(changeType: changeType, events: events) else {
                return PlayerActionError.invalidAction(message: "Duplicate events detected!")
            }
        case .buyOrSell(let player, let itemParameter, let item):
            player.buy(itemParameter: itemParameter, quantity: item)
            // TODO: Return the eval from buying
        }
        return nil
    }

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

    func watchMasterUpdate(gameState: GenericGameState) {
        if isBlocking {
            return
        }
        switch state {
        case .waitForStateUpdate:
            break
        default:
            return
        }
        isBlocking = true
        // update here? Not updating though
        isBlocking = false
    }

    func watchTurnFinished(playerActions: [(GenericPlayer, [PlayerAction])]) {
        // make player actions
        if isBlocking {
            return
        }
        switch state {
        case .waitForTurnFinish:
            return
        default:
            break
        }
        isBlocking = true
        for (player, actions) in playerActions {
            evaluateState(player: player, actions: actions)
        }
        updateStateMaster()
        isBlocking = false
    }

    func endTurn() {
        _currentPlayer = getNextPlayer()
        for callback in callbacks {
            callback()
        }
    }

    func endTurnCallback(action: @escaping () -> Void) {
        callbacks.append(action)
    }

    func getNextPlayer() -> GenericPlayer? {
        let players = gameState.getPlayers()
            .filter { [weak self] in $0.deviceId == self?.deviceId }
        data.currentPlayerIndex += 1
        if !players.indices.contains(data.currentPlayerIndex) {
            data.currentPlayerIndex = 0
            return nil
        }

        return players[data.currentPlayerIndex]
    }

    private func evaluateState(player: GenericPlayer, actions: [PlayerAction]) {
        var actions = actions
        while !actions.isEmpty {
            while checkForEvents() {
            }
            if !(makeAction(for: player, action: actions.removeFirst()) != nil) {
                print("Invalid action from server, dropping action")
            }
        }
    }

    private func checkForEvents() -> Bool {
        if data.triggeredEvents.isEmpty {
            return false
        }
        for event in data.triggeredEvents {
            event.executeActions()
        }
        return true
    }

    private func updateStateMaster() {
        // TODO: Interface with network
    }

}
