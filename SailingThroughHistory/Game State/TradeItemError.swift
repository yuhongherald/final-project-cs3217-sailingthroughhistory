//
//  BuyItemError.swift
//  SailingThroughHistory
//
//  Created by Herald on 3/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum TradeItemError: Error {
    case insufficientFunds(shortOf: Int)
    case insufficientItems(shortOf: Int, sold: Int)
    case insufficientCapacity(shortOf: Int)
    case notDocked
    case itemNotAvailable
    case unknownItem
    case purchaseSuccess(item: GenericItem)
    case sellSuccess(item: GenericItem)
    case sellTypeSuccess(itemType: ItemType, quantity: Int)

    func getMessage() -> String {
        switch self {
        case .insufficientFunds(let amount):
            return "Short of \(amount) money!" // TODO: Get currency name
        case .insufficientItems(let amount, let sold):
            return "Short of \(amount) items! Only \(sold) were sold."
        case .insufficientCapacity(let amount):
            return "Short of \(amount) capacity!"
        case .itemNotAvailable:
            return "Item not available at port!"
        case .notDocked:
            return "Player is not at a port!"
        case .unknownItem:
            return "Unknown item. Please contact the developers ASAP"
        case .purchaseSuccess(let item):
            return "Item purchase of \(item.name) with \(item.quantity) quantity is successful!"
        case .sellSuccess(let item):
            return "\(item.name) with \(item.quantity) quantity sold successfully!"
        case .sellTypeSuccess(let itemType, let quantity):
            return "\(itemType) with \(quantity) quantity sold successfully!"
        }
    }
}
