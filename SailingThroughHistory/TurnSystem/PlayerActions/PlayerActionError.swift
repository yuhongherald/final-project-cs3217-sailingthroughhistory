//
//  PlayerActionError.swift
//  SailingThroughHistory
//
//  Created by Herald on 2/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum PlayerActionError: Error {
    case invalidAction(message: String)
    case wrongPhase(message: String)

    func getMessage() -> String {
        switch self {
        case .invalidAction(message: let message):
            return message
        case .wrongPhase(message: let message):
            return message
        }
    }
}
