//
//  TurnSystemActionAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/*
 class TurnSystemActionAdapter {
    let stateVariable: GameVariable<TurnSystemNetwork.State>
    let playerActionAdapter: GenericPlayerActionAdapter
    let networkActionQueue = DispatchQueue(label: "com.CS3217.networkActionQueue")
    let networkInfo: NetworkInfo
    let data: GenericTurnSystemState

    var deviceId: String {
        return networkInfo.deviceId
    }

    var gameState: GenericGameState {
        return data.gameState
    }

    var messages: [GameMessage] {
        get {
            return data.messages
        }
        set {
            data.messages = newValue
        }
    }

    var state: TurnSystemNetwork.State {
        get {
            return stateVariable.state
        }
        set {
            stateVariable.state = newValue
        }
    }

    init(stateVariable: GameVariable<TurnSystemNetwork.State>,
         playerActionAdapter: GenericPlayerActionAdapter,
         networkInfo: NetworkInfo, data: GenericTurnSystemState) {
        self.stateVariable = stateVariable
        self.playerActionAdapter = playerActionAdapter
        self.networkInfo = networkInfo
        self.data = data
    }

    func evaluateState(player: GenericPlayer, actions: [PlayerAction])
        -> [GameMessage] {
            var actions = actions
            state = .evaluateMoves(for: player)
            var result = [GameMessage]()
            while !actions.isEmpty {
                do {
                    if let message = try playerActionAdapter.process(action: actions.removeFirst(), for: player) {
                        result.append(message)
                    }
                } catch {
                    print("Invalid action from server, dropping action")
                }
            }
            return result
    }

    func processNetworkTurnActions(forTurnNumber turnNum: Int, playerActionPairs: [(String, [PlayerAction])]) {
        switch state {
        case .waitForTurnFinish:
            break
        default:
            return
        }
        if currentTurn != turnNum {
            return
        }
        for player in players where
            playerActionPairs.first(where: { player.playerName.hasPrefix($0.0) }) == nil {
                return
        }
        
    }

    func processTurnActions(forTurnNumber turnNum: Int, playerActionPairs: [(String, [PlayerAction])]) {
        networkActionQueue.sync { [weak self] in
            self?.processNetworkTurnActions(forTurnNumber: turnNum, playerActionPairs: playerActionPairs)
        }
        for playerActionPair in playerActionPairs {
            guard let chosenPlayer =
                self.gameState.getPlayers().first(where: { $0.name == playerActionPair.0 }) else {
                    continue
            }
            let playerActions = self.evaluateState(player: chosenPlayer, actions: playerActionPair.1)
            self.messages.append(contentsOf: playerActions)
            let messages = chosenPlayer.endTurn()
            if chosenPlayer.deviceId == deviceId {
                self.messages.append(contentsOf: messages.map { GameMessage.playerAction(name: chosenPlayer.name,
                                                                                         message: $0.message)})
            }
        }
        gameState.map.npcs.forEach {
            guard let node = $0.moveToNextNode(map: gameState.map, maxTaxAmount: 2000) else {
                return
            }
            self.messages.append(GameMessage.playerAction(name: "NPC", message: "An npc has moved into \(node.name)"))
        }
        playerActionAdapter.handleSetTax()
        let eventResults = data.checkForEvents() // events will run here, non-recursive
        self.messages.append(contentsOf: eventResults)
        gameState.gameTime.value.addWeeks(4)
        gameState.map.updateWeather(for: gameState.gameTime.value.month)
        gameState.distributeTeamMoney()
        
        updateStateMaster()
    }
    
    func commitEndTurn(_ currentPlayer: GenericPlayer) {
        let currentTurn = self.currentTurn
        let pendingActions = self.pendingActions
        do {
            try network.push(
                actions: pendingActions, fromPlayer: currentPlayer,
                forTurnNumbered: currentTurn) { [weak self] error in
                    guard let self = self, error != nil else {
                        return
                    }
                    /// Usually firebase will resend after internet connection is re-established,
                    /// but we resend it just in-case
                    try? self.network.push(actions: pendingActions, fromPlayer: currentPlayer,
                                           forTurnNumbered: currentTurn) { _ in }
            }
        } catch {
            fatalError("Unable to encode actions.")
        }
    }
    
    func updateStateMaster() {
        state = .waitForStateUpdate
        if isMaster {
            guard let gameState = gameState as? GameState else {
                return
            }
            let currentTurn = self.currentTurn
            do {
                try network.push(currentState: gameState, forTurn: currentTurn) {
                    guard let error = $0 else {
                        return
                    }
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        /// The game state parameter is ignored for now, validation can be added here
        network.subscribeToMasterState(for: currentTurn) { [weak self] networkGameState in
            self?.data.turnFinished()
            if let data = self?.data, let gameState = self?.gameState {
                if data.currentTurn >= gameState.numTurns {
                    let winner = gameState.getTeamMoney().max { (first, second) -> Bool in
                        return first.value < second.value
                        }?.key
                    self?.state = .finished(winner: winner)
                    return
                }
            }
            guard let player = self?.getFirstPlayer() else {
                self?.state = .waitForTurnFinish
                return
            }
            self?.state = .waitPlayerInput(from: player)
            guard let gameState = self?.gameState else {
                return
            }
            //assert(gameState.description == networkGameState.description)
        }
    }
}
*/
