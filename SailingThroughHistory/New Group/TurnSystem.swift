//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystem: GenericTurnSystem {
    enum State {
        case ready(player: GenericPlayer)
        case waitForTurnFinish
        case waitForStateUpdate
        case invalid
    }
    private var state: State
    private let network: RoomConnection
    private var isBlocking = false
    private let isMaster: Bool
    var data: GenericTurnSystemState
    private let deviceId: String
    var gameState: GameState {
        return data.gameState
    }

    init(isMaster: Bool, network: RoomConnection, startingState: GameState, deviceId: String) {
        self.deviceId = deviceId
        self.network = network
        self.isMaster = isMaster
        self.data = TurnSystemState(gameState: startingState)
        self.state = .invalid
        guard let player = getNextPlayer() else {
            fatalError("No players belong on this device/")
        }
        state = .ready(player: player)
    }

    // TODO: Add to protocol and also do a running gamestate
    func startGame() {
        state = .waitForTurnFinish
    }

    // for testing
    func getState() -> TurnSystem.State {
        return state
    }

    /// Returns false if action is invalid
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> Bool {
        //player.
        switch state {
        case .waitForTurnFinish:
            return false
        default:
            break
        }
        switch action {
        case .changeInventory(changeType: let changeType, money: let money, items: let items):
            // TODO: Discuss player API
            //player.getMaxPurchaseAmount(itemParameter: )
            return false
        case .roll:
            if player.hasRolled {
                return false
            }
            _ = player.roll()
            return true
        case .move(to: let node):
            if !player.hasRolled {
                return false
            }
            if !player.getNodesInRange(roll: player.roll()).contains(node) {
                return false
            }
            player.move(node: node)
            return true
        case .forceMove(to: let node): // quick hack for updating the player's position remotely
            player.move(node: node)
            return true
        case .setTax(for: let port, let taxAmount):
            guard player == port.owner else { // TODO: Fix equality assumption
                return false
            }
        port.taxAmount = taxAmount
        return true
        case .setEvent(changeType: let changeType, events: let events):
            return setEvents(changeType: changeType, events: events)
        }
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

    // TODO: Fix the gamestate sent back
    func watchMasterUpdate(gameState: GenericGameState) {
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
        guard let nextPlayer = getNextPlayer() else {
            return
        }


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
            if !makeAction(for: player, action: actions.removeFirst()) {
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
