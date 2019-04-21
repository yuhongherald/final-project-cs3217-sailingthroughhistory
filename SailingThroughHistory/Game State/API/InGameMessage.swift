//
//  InGameMessage.swift
//  SailingThroughHistory
//
//  Created by henry on 2/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines a generic message that can represent an error or information message, in
/// the game.
import Foundation

enum InGameMessage {
    case info(message: String)
    case error(message: String)

    func getMsg() -> String {
        switch self {
        case .info(let msg):
            return msg
        case .error(let msg):
            return msg
        }
    }
}
