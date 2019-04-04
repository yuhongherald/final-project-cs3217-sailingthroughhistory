//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Port: Node {
    public var taxAmount = 0
    public var owner: Team? {
        didSet {
            self.ownerName = self.owner?.name
        }
    }
    public var ownerName: String?
    // TODO: add item quantity editing in level editor
    var itemParametersSoldByPort = [ItemType]()
    var itemParametersBoughtByPort = [ItemType]()
    var itemSellValue = [ItemType: Int]()
    var itemBuyValue = [ItemType: Int]()

    private static let portNodeWidth: Double = 50
    private static let portNodeHeight: Double = 50

    init(team: Team, originX: Double, originY: Double) {
        let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth)
        owner = team
        super.init(name: team.name, frame: frame)
    }

    init(team: Team?, name: String, originX: Double, originY: Double) {
        let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth)

        super.init(name: name, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerName = try values.decode(String?.self, forKey: .ownerName)
        itemBuyValue = try values.decode([ItemType: Int].self, forKey: .itemBuyValue)
        itemSellValue = try values.decode([ItemType: Int].self, forKey: .itemSellValue)
        itemParametersSoldByPort = itemBuyValue.keys.map( { $0 })
        itemParametersSoldByPort = itemSellValue.keys.map( { $0 })
        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner?.name, forKey: .ownerName)
        try container.encode(itemBuyValue, forKey: .itemBuyValue)
        try container.encode(itemSellValue, forKey: .itemSellValue)
        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }

    public func assignOwner(_ team: Team?) {
        owner = team
    }

    public func collectTax(from player: Player) {
        // Prevent event listeners from firing unneccessarily
        if player.team == owner {
            return
        }
        player.updateMoney(by: -taxAmount)
        owner?.updateMoney(by: taxAmount)
    }

    func getBuyValue(of type: ItemParameter) -> Int? {
        return itemBuyValue[type.itemType]
    }

    func getSellValue(of type: ItemParameter) -> Int? {
        return itemSellValue[type.itemType]
    }

    func setBuyValue(of type: ItemParameter, value: Int) {
        if itemBuyValue[type.itemType] == nil {
            itemParametersSoldByPort.append(type.itemType)
        }
        itemBuyValue[type.itemType] = value
    }

    func setSellValue(of type: ItemParameter, value: Int) {
        if itemSellValue[type.itemType] == nil {
            itemParametersSoldByPort.append(type.itemType)
        }
        itemSellValue[type.itemType] = value
    }

    // Availability at ports
    func delete(_ type: ItemParameter) {
        if getBuyValue(of: type) != nil {
            itemParametersSoldByPort.removeAll(where: { $0 == type.itemType })
            itemBuyValue.removeValue(forKey: type.itemType)
        }
        if getSellValue(of: type) != nil {
            itemParametersBoughtByPort.removeAll(where: { $0 == type.itemType })
            itemSellValue.removeValue(forKey: type.itemType)
        }
    }

    func getAllItemType() -> [ItemType] {
        // default/placeholder for all items
        return Array(Set(itemParametersSoldByPort + itemParametersBoughtByPort))
    }

    private enum CodingKeys: String, CodingKey {
        case ownerName
        case itemParameters
        case itemBuyValue
        case itemSellValue
    }
}
