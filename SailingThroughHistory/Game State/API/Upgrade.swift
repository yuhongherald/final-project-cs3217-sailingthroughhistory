//
//  Upgrades.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines the requirements of an upgrade for a ship.
import Foundation

protocol Upgrade: Codable {
    var name: String { get }
    var cost: Int { get }
    var type: UpgradeType { get }

    func getNewSuppliesConsumed(baseConsumption: [GenericItem]) -> [GenericItem]
    func getMovementModifier() -> Double
}
