//
//  ShipAPI.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol ShipAPI {
    var name: String { get }
    var isChasedByPirates: Bool { get set }
    var turnsToBeingCaught: Int { get set }
    var shipChassis: ShipChassis? { get set }
    var auxiliaryUpgrade: AuxiliaryUpgrade? { get set }

    var nodeId: Int { get set }
    var currentCargoWeight: Int { get }
    var weightCapacity: Int { get set }
    var nodeIdVariable: GameVariable<Int> { get }
    var owner: GenericPlayer? { get set }
    var items: GameVariable<[GenericItem]> { get set }
    var isDocked: Bool { get set }

    var shipObject: ShipUI? { get set }
    var map: Map? { get set }

    init(node: Node, suppliesConsumed: [GenericItem])
    func setOwner(owner: GenericPlayer)
    func setMap(map: Map)
    func startTurn()
    func endTurn(speedMultiplier: Double) -> [InfoMessage]
    func getCurrentNode() -> Node

}
