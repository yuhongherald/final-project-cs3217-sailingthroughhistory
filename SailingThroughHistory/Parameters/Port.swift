//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//
import UIKit

class Port: Node {
    // Changed GenericPlayer
    public var taxAmount = 0
    public var owner: Player?
    public var itemParametersSold = [ItemParameter]()

    private static let portNodeSize = CGSize(width: 50, height: 50)
    private static let portNodeImage = "port-node.png"

    init(player: Player, pos: CGPoint) {
        owner = player
        super.init(name: player.name, image: Port.portNodeImage, frame: CGRect(origin: pos, size: Port.portNodeSize))
    }

    init(player: Player?, name: String, pos: CGPoint) {
        super.init(name: name, image: Port.portNodeImage, frame: CGRect(origin: pos, size: Port.portNodeSize))
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        owner = try values.decode(Player.self, forKey: .owner)
        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner, forKey: .owner)

        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }

    public func assignOwner(_ player: Player) {
        owner = player
    }

    public func collectTax(from player: Player) {
        // Prevent event listeners from firing unneccessarily
        if player == owner {
            return
        }
        player.money.value -= taxAmount
        owner?.money.value += taxAmount
    }

    private enum CodingKeys: String, CodingKey {
        case owner
    }
}
