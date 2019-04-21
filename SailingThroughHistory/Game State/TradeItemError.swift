//
//  BuyItemError.swift
//  SailingThroughHistory
//
//  Created by Herald on 3/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents the various error types that are thrown when trading items.
enum TradeItemError: Error {
    case insufficientFunds(shortOf: Int)
    case insufficientItems(shortOf: Int, sold: Int)
    case insufficientCapacity(shortOf: Int)
    case notDocked
    case itemNotAvailable
    case purchaseSuccess(item: GenericItem)
    case sellSuccess(item: GenericItem)
    case sellTypeSuccess(itemParameter: ItemParameter, quantity: Int)

    func getMessage() -> String {
        switch self {
        case .insufficientFunds(let amount):
            return "Short of \(amount) money!"
        case .insufficientItems(let amount, let sold):
            return "Short of \(amount) items! Only \(sold) were sold."
        case .insufficientCapacity(let amount):
            return "Short of \(amount) weight capacity!"
        case .itemNotAvailable:
            return "Item not available at port!"
        case .notDocked:
            return "Player is not at a port!"
        case .purchaseSuccess(let item):
            return "Item purchase of \(item.name) with \(item.quantity) quantity is successful!"
        case .sellSuccess(let item):
            return "\(item.name) with \(item.quantity) quantity sold successfully!"
        case .sellTypeSuccess(let itemParameter, let quantity):
            return "\(itemParameter) with \(quantity) quantity sold successfully!"
        }
    }
}
