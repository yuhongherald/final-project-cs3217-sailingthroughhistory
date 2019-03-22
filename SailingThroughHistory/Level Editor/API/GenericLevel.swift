//
//  GenericLevel.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericLevel {
    var itemParameters: Set<ItemParameter> { get set }

    func getPlayers() -> [GenericPlayer]
    func getMap() -> Map
    func getItemLocations() -> [Port: [Item]]
}
