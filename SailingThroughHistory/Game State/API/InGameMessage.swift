//
//  InGameMessage.swift
//  SailingThroughHistory
//
//  Created by henry on 2/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

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
