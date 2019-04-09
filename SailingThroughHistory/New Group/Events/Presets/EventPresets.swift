//
//  EventPresetsFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventPresets {
    enum Event {
        case monsoon(activate: Bool)
        case neutralTax(operand: String) // split into add sub mult div
        case itemPrice(for: ItemType, operand: String) // split into item types
        case playerDeath(for: GenericPlayer)
    }
    private let monsoonEvents: [Bool: TurnSystemEvent]
    private let neutralTaxEvents: [String: TurnSystemEvent]
    private let itemPriceEvents: [String: [String: TurnSystemEvent]]
    private let playerDeathEvents: [String: TurnSystemEvent]
    private let eventTable: EventTable

    init(gameState: GenericGameState) {
        // monsoon []
        // taxes []
        // item price []
        // player death []
        eventTable = EventTable()
        var monsoonEvents: [Bool: TurnSystemEvent] = [Bool: TurnSystemEvent]()
        var neutralTaxEvents: [String: TurnSystemEvent] = [String: TurnSystemEvent]()
        var itemPriceEvents: [String: [String: TurnSystemEvent]] = [String: [String: TurnSystemEvent]]()
        var playerDeathEvents: [String: TurnSystemEvent] = [String: TurnSystemEvent]()

        monsoonEvents[true] = eventTable.pushEvent(
            event: HeavyMonsoonEvent(gameState: gameState,
                                     start: PresetConstants.monsoonStart,
                                     end: PresetConstants.monsoonEnd)) // call push on table for each construct

        var evaluators = 0.evaluators
        for index in 0..<evaluators.count {
            let key = evaluators[index].displayName
            neutralTaxEvents[key] = eventTable.pushEvent(
                event: TaxChangeEvent(gameState: gameState,
                                      genericOperator: evaluators[index],
                                      modifier: PresetConstants.taxModifiers[index]))
            itemPriceEvents[key] = [String: TurnSystemEvent]()
            for item in ItemType.allCases {
                itemPriceEvents[key]?[item.rawValue] = eventTable.pushEvent(
                    event: ItemPriceEvent(gameState: gameState,
                                          itemType: item,
                                          genericOperator: evaluators[index],
                                          modifier: PresetConstants.priceModifers[index]))
            }
        }

        for player in gameState.getPlayers() {
            playerDeathEvents[player.deviceId] = eventTable.pushEvent(
                event: NegativeMoneyEvent(player: player))
        }

        self.monsoonEvents = monsoonEvents
        self.neutralTaxEvents = neutralTaxEvents
        self.itemPriceEvents = itemPriceEvents
        self.playerDeathEvents = playerDeathEvents
    }
    func getEvent(event: Event) -> TurnSystemEvent? {
        switch event {
        case .monsoon(activate: let activate):
            return monsoonEvents[activate]
        case .neutralTax(operand: let operand):
            return neutralTaxEvents[operand]
        case .itemPrice(for: let itemType, operand: let operand):
            return itemPriceEvents[operand]?[itemType.rawValue]
        case .playerDeath(for: let player):
            return playerDeathEvents[player.deviceId]
        }
    }
    func getEvent(id: Int) -> TurnSystemEvent? {
        return eventTable.getEvent(id: id)
    }
}
