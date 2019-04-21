//
//  MercernaryUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// An Auxiliary Upgrade that gives ships immunity to pirates.
import Foundation

class MercernaryUpgrade: AuxiliaryUpgrade {
    override var type: UpgradeType {
         return .mercernary
    }
    override var name: String {
        return "Mercernary"
    }
    override var cost: Int {
        return 1000
    }
}
