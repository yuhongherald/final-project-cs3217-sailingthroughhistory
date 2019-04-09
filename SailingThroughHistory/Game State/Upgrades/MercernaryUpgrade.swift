//
//  MercernaryUpgrade.swift
//  SailingThroughHistory
//
//  Created by henry on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class MercernaryUpgrade: AuxiliaryUpgrade {
    override var name: String {
        return "Mercernary"
    }
    override var cost: Int {
        return 1000
    }

    override func handleEvent() {
        // TODO: Handle event to ignore pirate
    }
}
