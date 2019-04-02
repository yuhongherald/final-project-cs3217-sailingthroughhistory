//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Port: Node {
    public var taxAmount = 0
    public var owner: Player?
    private var itemParameters: [ItemType: ItemParameter] = {
        var dictionary = [ItemType: ItemParameter]()
        ItemType.getAll().forEach {
            dictionary[$0] = ItemParameter(itemType: $0, displayName: $0.rawValue, weight: 0, isConsumable: true)
        }
        return dictionary
    }()
    // TODO: add item quantity editing in level editor
    var itemParametersSold = [ItemParameter]()

    private static let portNodeWidth: Double = 50
    private static let portNodeHeight: Double = 50
    private static let portNodeImage = "port-node.png"

    init(player: Player, originX: Double, originY: Double) {
        guard let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth) else {
                                fatalError("Port dimensions are invalid.")
        }
        owner = player
        super.init(name: player.name, image: Port.portNodeImage, frame: frame)
    }

    init(player: Player?, name: String, originX: Double, originY: Double) {
        guard let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth) else {
                                fatalError("Port dimensions are invalid.")
        }

        super.init(name: name, image: Port.portNodeImage, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let ownerName = try values.decode(String?.self, forKey: .ownerName)
        let ownerTeam = try values.decode(Team?.self, forKey: .ownerTeam)
        itemParameters = try values.decode([ItemType: ItemParameter].self, forKey: .itemParameters)
        itemParametersSold = try values.decode([ItemParameter].self, forKey: .itemsSold)
        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
        guard let name = ownerName, let team = ownerTeam else {
            owner = nil
            return
        }
        // TODO
        //owner = Player(name: name, team: team, node: self, deviceId: "")
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner?.name, forKey: .ownerName)
        try container.encode(owner?.team, forKey: .ownerTeam)
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(itemParametersSold, forKey: .itemsSold)

        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }

    public func assignOwner(_ player: Player?) {
        owner = player
    }

    public func collectTax(from player: Player) {
        // Prevent event listeners from firing unneccessarily
        if player == owner || player.team == owner?.team {
            return
        }
        player.updateMoney(by: -taxAmount)
        owner?.updateMoney(by: taxAmount)
    }

    func getBuyValue(of type: ItemType) -> Int? {
        return itemParameters[type]?.getBuyValue()
    }

    func getSellValue(of type: ItemType) -> Int? {
        return itemParameters[type]?.getSellValue()
    }

    func setBuyValue(of type: ItemType, value: Int) {
        itemParameters[type]?.setBuyValue(value: value)
    }

    func setSellValue(of type: ItemType, value: Int) {
        itemParameters[type]?.setSellValue(value: value)
    }

    // Availability at ports
    func delete(_ type: ItemType) {
        itemParameters[type] = nil
    }

    func getItemParametersSold() -> [ItemParameter] {
        var itemParametersSold = [ItemParameter]()
        for itemParameter in itemParameters.values {
            if itemParametersSold.contains(where: { item in item.itemType == itemParameter.itemType }) {
                itemParametersSold.append(itemParameter)
            }
        }
        return itemParametersSold
    }

    func getAllItemParameters() -> [ItemParameter] {
        // default/placeholder for all items
        return Array(itemParameters.values)
    }

    private enum CodingKeys: String, CodingKey {
        case ownerName
        case ownerTeam
        case itemParameters
        case itemsSold
    }
}
