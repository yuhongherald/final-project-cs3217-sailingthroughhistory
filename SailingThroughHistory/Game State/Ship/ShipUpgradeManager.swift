//
//  ShipUpgradeManager.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Handles purchasing of Upgrades. Stateless.
import Foundation

class ShipUpgradeManager: Upgradable {
    func installUpgrade(ship: inout ShipAPI, upgrade: Upgrade) -> (Bool, InfoMessage?) {
        guard let owner = ship.owner else {
            return (false, InfoMessage.noOwner)
        }
        guard owner.money.value >= upgrade.cost else {
            return (false, InfoMessage.cannotAfford(upgrade: upgrade))
        }
        if ship.shipChassis == nil, let shipUpgrade = upgrade as? ShipChassis {
            owner.updateMoney(by: -upgrade.cost)
            ship.shipChassis = shipUpgrade
            return (true, InfoMessage.upgradePurchased(upgrade: upgrade))
        }
        if ship.auxiliaryUpgrade == nil, let auxiliary = upgrade as? AuxiliaryUpgrade {
            owner.updateMoney(by: -upgrade.cost)
            ship.auxiliaryUpgrade = auxiliary
            return (true, InfoMessage.upgradePurchased(upgrade: upgrade))
        }
        if upgrade is ShipChassis {
            return (false, InfoMessage.duplicateUpgrade(type: "Ship Upgrade"))
        } else if upgrade is AuxiliaryUpgrade {
            return (false, InfoMessage.duplicateUpgrade(type: "Auxiliary Upgrade"))
        }
        return (false, nil)
    }
}
