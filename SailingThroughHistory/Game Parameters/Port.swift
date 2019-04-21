//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * Model for port to store owner, tax and items.
 */
class Port: Node {
    var taxAmount: GameVariable<Int> = GameVariable(value: 0)
    var owner: Team? {
        didSet {
            self.ownerName = self.owner?.name
        }
    }
    var ownerName: String?
    var itemParametersSoldByPort: [ItemParameter] {
        return [ItemParameter](itemBuyValue.keys)
    }
    var itemParametersBoughtByPort: [ItemParameter] {
        return [ItemParameter](itemSellValue.keys)
    }
    var itemSellValue = [ItemParameter: Int]()
    var itemBuyValue = [ItemParameter: Int]()

    private static let portNodeWidth: Double = 50
    private static let portNodeHeight: Double = 50

    init(team: Team, originX: Double, originY: Double) {
        let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth)
        owner = team
        super.init(name: team.name, frame: frame)
        initDefaultPrices()
    }

    init(team: Team?, name: String, originX: Double, originY: Double) {
        let frame = Rect(originX: originX, originY: originY, height: Port.portNodeHeight,
                               width: Port.portNodeWidth)

        super.init(name: name, frame: frame)
        initDefaultPrices()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerName = try values.decode(String?.self, forKey: .ownerName)
        itemBuyValue = try values.decode([ItemParameter: Int].self, forKey: .itemBuyValue)
        itemSellValue = try values.decode([ItemParameter: Int].self, forKey: .itemSellValue)
        taxAmount.value = try values.decode(Int.self, forKey: .tax)
        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner?.name, forKey: .ownerName)
        try container.encode(itemBuyValue, forKey: .itemBuyValue)
        try container.encode(itemSellValue, forKey: .itemSellValue)
        try container.encode(taxAmount.value, forKey: .tax)
        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }

    /// Assign the ownership of the port to the team.
    /// - Parameters:
    ///   - team: new owner of the port
    public func assignOwner(_ team: Team?) {
        owner = team
    }

    /// Collecte tax from the player and pay tax to port owner.
    /// - Parameters:
    ///   - player: player to collect tax from
    public func collectTax(from player: GenericPlayer) {
        // Prevent event listeners from firing unneccessarily
        if player.team == owner {
            return
        }
        player.updateMoney(by: -taxAmount.value)
        owner?.updateMoney(by: taxAmount.value)
    }

    /// Collecte tax from the NPC and pay tax to port owner.
    /// - Parameters:
    ///   - npc: NPC to collect tax from
    public func collectTax(from npc: NPC) {
        owner?.updateMoney(by: taxAmount.value)
    }

    /// Get export price of item.
    func getBuyValue(of type: ItemParameter) -> Int? {
        return itemBuyValue[type]
    }

    /// Get import price of item.
    func getSellValue(of type: ItemParameter) -> Int? {
        return itemSellValue[type]
    }

     /// Set export price of item to value.
    func setBuyValue(of type: ItemParameter, value: Int) {
        let finalValue = max(getSellValue(of: type) ?? 0, value)
        itemBuyValue[type] = finalValue
    }

    /// Set import price of item to value.
    func setSellValue(of type: ItemParameter, value: Int) {
        let finalValue = min(getBuyValue(of: type) ?? value, value)
        itemSellValue[type] = finalValue
    }

    /// Remove availability of items at ports
    func delete(_ type: ItemParameter) {
        if getBuyValue(of: type) != nil {
            itemBuyValue.removeValue(forKey: type)
        }
        if getSellValue(of: type) != nil {
            itemSellValue.removeValue(forKey: type)
        }
    }

    /// Get item parameters of all available items
    func getAllItemParameters() -> [ItemParameter] {
        // default/placeholder for all items
        return Array(Set(itemParametersSoldByPort + itemParametersBoughtByPort))
    }

    private func initDefaultPrices() {
        ItemParameter.allCases.forEach { [weak self] itemType in
            self?.itemSellValue[itemType] = ItemParameter.defaultPrice
            self?.itemBuyValue[itemType] = ItemParameter.defaultPrice
        }
    }

    private enum CodingKeys: String, CodingKey {
        case ownerName
        case itemParameters
        case itemBuyValue
        case itemSellValue
        case tax
    }
}
