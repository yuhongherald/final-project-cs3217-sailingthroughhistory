//
//  AvailableUpgradesControllerDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Delegate for AvailableUpgradesController. Notified when the user wishes to buy an upgrade.
protocol AvailableUpgradesControllerDelegate: class {
    func buy(upgrade: Upgrade)
}
