//
//  UpgradeType.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 10/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Used for encoding/decoding the various types of ship Upgrades.
enum UpgradeType: Int, Codable {
    case biggerShip
    case fasterShip
    case biggerSails
    case mercernary
    case baseShip
    case baseAuxillary

    func toUpgrade() -> Upgrade {
        switch self {
        case .biggerShip:
            return BiggerShipUpgrade()
        case .fasterShip:
            return FasterShipUpgrade()
        case .biggerSails:
            return BiggerSailsUpgrade()
        case .mercernary:
            return MercernaryUpgrade()
        case .baseShip:
            return ShipChassis()
        case .baseAuxillary:
            return AuxiliaryUpgrade()
        }
    }
}
