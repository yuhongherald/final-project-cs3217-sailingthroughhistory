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
    private var state: State = .ready
    private var isBlocking: Bool = false
    var data: GenericTurnSystemState
    var isMaster: Bool = true

    init(isMaster: Bool, data: GenericTurnSystemState) {
        self.isMaster = isMaster
        self.data = data
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
        if state != .waitForTurnFinish {
            return false
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
        if state != .waitForStateUpdate || isBlocking {
            return
        }
        isBlocking = true
        isBlocking = false
    }

    func watchTurnFinished(playerActions: [(GenericPlayer, [PlayerAction])]) {
        // make player actions
        if state != .waitForTurnFinish || isBlocking {
            return
        }
        isBlocking = true
        for (player, actions) in playerActions {
            evaluateState(player: player, actions: actions)
        }
        updateStateMaster()
        isBlocking = false
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
