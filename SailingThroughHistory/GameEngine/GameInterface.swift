//
//  GameInterface.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import RxSwift

class GameInterface {
    private let interface: Interface
    init(interface: Interface) {
        self.interface = interface
    }

    func startPlayerTurn(player: GenericPlayer, callback: @escaping () -> Void) {
        let time = TimeInterval(exactly: GameConstants.playerTurnDuration)
        interface.playerTurnStart(player: player, timeLimit: time,
                                  timeOutCallback: callback)
    }
    
    func showNotification(message: VisualAudioData) {
        //interface.displayMessage(data: message)
        let msg = "message"//message.visualData.contextualData.toString()
        interface.pauseAndShowAlert(titled: "Game Message", withMsg: msg)
    }

    func registerCallback(for gameEngine: GameEngine) {
        interface.subscribe{
            guard let events = $0.element else {
                return
            }
            for event in events.events {
                switch event {
                case .pauseGame:
                    gameEngine.asyncPause()
                case .resumeGame:
                    gameEngine.asyncResume(invalidateCache: false)
                case .playerTurnEnd:
                    gameEngine.asyncResume(invalidateCache: true)
                default:
                    break
                }
            }
        }
    }

}
