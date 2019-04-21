//
//  ShipAPI.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines the behaviors that a Ship needs to support. A ship can be owned by a
/// player.
import Foundation

protocol ShipAPI: Pirate_WeatherEntity {
    var itemManager: ItemStorage { get }
    var upgradeManager: Upgradable { get }
    var navigationManager: Navigatable { get }

    var name: String { get }
    var isChasedByPirates: Bool { get set }
    var turnsToBeingCaught: Int { get set }
    var shipChassis: ShipChassis? { get set }
    var auxiliaryUpgrade: AuxiliaryUpgrade? { get set }

    var nodeId: Int { get set }
    var node: Node { get }
    var currentCargoWeight: Int { get }
    var weightCapacity: Int { get set }
    var nodeIdVariable: GameVariable<Int> { get }
    var owner: GenericPlayer? { get set }
    var items: GameVariable<[GenericItem]> { get set }
    var isDocked: Bool { get set }

    var shipObject: ShipUI? { get set }
    var map: Map? { get set }

    func startTurn()
    func endTurn(speedMultiplier: Double) -> [InfoMessage]
    func updateCargoWeight(items: [GenericItem])

}
