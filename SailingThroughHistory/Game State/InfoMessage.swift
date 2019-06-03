//
//  InfoMessage.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents various messages for interactions in the game.
import Foundation

enum InfoMessage {
    case pirates(turnsToBeingCaught: Int)
    case caughtByPirates
    case deficit(itemName: String, deficit: Int)
    case noOwner
    case cannotAfford(upgrade: Upgrade)
    case upgradePurchased(upgrade: Upgrade)
    case duplicateUpgrade(type: String)

    func getTitle() -> String {
        switch self {
        case .pirates, .caughtByPirates:
            return "Pirates"
        case .deficit:
            return "Item Deficit"
        case .noOwner:
            return "Error"
        case .cannotAfford:
            return "Insufficient Money"
        case .upgradePurchased:
            return "Ship Upgrade Purchsed"
        case .duplicateUpgrade:
            return "Duplicate Upgrade"
        }
    }

    func getMessage() -> String {
        switch self {
        case .pirates(let turnsToBeingCaught):
            return "\(turnsToBeingCaught) more turns to being caught!"
        case .caughtByPirates:
            return "You have been caught by pirates!. You lost all your cargo"
        case .deficit(let itemName, let deficit):
            return "You have exhausted \(itemName) and have a deficit"
                + " of \(deficit) and paid twice the normal amount for it."
        case .noOwner:
            return "Ship has no owner!"
        case .cannotAfford(let upgrade):
            return "You do not have sufficient funds to buy \(upgrade.name)!"
        case .upgradePurchased(let upgrade):
            return "You have purchased \(upgrade.name)!"
        case .duplicateUpgrade(let type):
            return "You already have an upgrade of type \"\(type)\"!"
        }
    }

}
