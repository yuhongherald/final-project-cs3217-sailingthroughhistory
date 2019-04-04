//
//  BuyItemError.swift
//  SailingThroughHistory
//
//  Created by Herald on 3/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum BuyItemError: Error {
    case insufficientFunds(shortOf: Int)
    case insufficientItems(shortOf: Int)
    case insufficientCapacity(shortOf: Int)
    case notDocked
    case itemNotAvailable
    case unknownItem

    func getMessage() -> String {
        switch self {
        case .insufficientFunds(shortOf: let amount):
            return "Short of \(amount) money!" // TODO: Get currency name
        case .insufficientItems(shortOf: let amount):
            return "Short of \(amount) items!"
        case .insufficientCapacity(shortOf: let amount):
            return "Short of \(amount) capacity!"
        case .itemNotAvailable:
            return "Item not available at port!"
        case .notDocked:
            return "Player is not at a port!"
        case .unknownItem:
            return "Unknown item. Please contact the developers ASAP"
        }
    }
}
