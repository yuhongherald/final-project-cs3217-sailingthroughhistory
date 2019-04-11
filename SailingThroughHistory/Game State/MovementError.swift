//
//  MovementError.swift
//  SailingThroughHistory
//
//  Created by henry on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

enum MovementError: Error {
    case unableToDock
    case invalidPort

    func getMessage() -> String {
        switch self {
        case .unableToDock:
            return "Ship is not located at a port for docking."
        case .invalidPort:
            return "Node is not a valid port."
        }
    }
}
