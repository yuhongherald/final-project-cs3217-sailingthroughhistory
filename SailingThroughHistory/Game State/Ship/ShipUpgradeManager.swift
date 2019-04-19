//
//  ShipUpgradeManager.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ShipUpgradeManager: Upgradable {
    func installUpgrade(ship: inout ShipAPI, upgrade: Upgrade) -> (Bool, InfoMessage?) {
        guard let owner = ship.owner else {
            return (false, InfoMessage(title: "Error", message: "Ship has no owner!"))
        }
        guard owner.money.value >= upgrade.cost else {
            return (false, InfoMessage(title: "Insufficient Money!",
                                       message: "You do not have sufficient funds to buy \(upgrade.name)!"))
        }
        if ship.shipChassis == nil, let shipUpgrade = upgrade as? ShipChassis {
            owner.updateMoney(by: -upgrade.cost)
            ship.shipChassis = shipUpgrade
            return (true, InfoMessage(title: "Ship upgrade purchased!", message: "You have purchased \(upgrade.name)!"))
        }
        if ship.auxiliaryUpgrade == nil, let auxiliary = upgrade as? AuxiliaryUpgrade {
            owner.updateMoney(by: -upgrade.cost)
            ship.auxiliaryUpgrade = auxiliary
            return (true, InfoMessage(title: "Ship upgrade purchased!", message: "You have purchased \(upgrade.name)!"))
        }
        if upgrade is ShipChassis {
            return (false, InfoMessage(title: "Duplicate upgrade",
                                       message: "You already have an upgrade of type \"Ship Upgrade\"!"))
        } else if upgrade is AuxiliaryUpgrade {
            return (false, InfoMessage(title: "Duplicate upgrade",
                                       message: "You already have an upgrade of type \"Auxiliary Upgrade\"!"))
        }
        return (false, nil)
    }
}
