//
//  Interface+Message.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension Interface {
    func showNotification(message: VisualAudioData?, callback: (() -> Void)?) {
        guard let message = message else {
            return
        }
        displayMessage(data: message)
        subscribe {
            guard let events = $0.element else {
                return
            }
            for event in events.events {
                switch event {
                case .closeNotification(titled: let title):
                    // continue game engine execution
                    break
                case .playerTurnEnd:
                    break
                default:
                    break
                }
            }
        }

    }
    
    func startPlayerTurn(player: GenericPlayer) {
        
    }
}
