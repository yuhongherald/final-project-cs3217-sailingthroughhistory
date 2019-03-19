//
//  Item.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol Item {
    var itemType: ItemType { get }
    var quantity: Int { get }

    func getValue(port: Port) -> Int
}
