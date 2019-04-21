//
//  EventPresetsFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class used to initialize the PresetEvents used in the game, with unique identifiers.
 */
class EventPresets {
    enum Event {
        case monsoon(activate: Bool)
        case neutralTax(operand: String) // split into add sub mult div
        case itemPrice(for: ItemParameter, operand: String) // split into item types
        case playerDeath(for: GenericPlayer)
    }
    private let monsoonEvents: [Bool: PresetEvent]
    private let neutralTaxEvents: [String: PresetEvent]
    private let itemPriceEvents: [String: [String: PresetEvent]]
    private let playerDeathEvents: [String: PresetEvent]
    private let eventTable: EventTable<PresetEvent>

    init(gameState: GenericGameState, turnSystem: GenericTurnSystem) {
        // monsoon []
        // taxes []
        // item price []
        // player death []
        eventTable = EventTable<PresetEvent>()
        var monsoonEvents: [Bool: PresetEvent] = [Bool: PresetEvent]()
        var neutralTaxEvents: [String: PresetEvent] = [String: PresetEvent]()
        let itemPriceEvents: [String: [String: PresetEvent]] = [String: [String: PresetEvent]]()
        var playerDeathEvents: [String: PresetEvent] = [String: PresetEvent]()
        /*
        monsoonEvents[true] = eventTable.pushEvent(
            event: HeavyMonsoonEvent(gameState: gameState,
                                     start: PresetConstants.monsoonStart,
                                     end: PresetConstants.monsoonEnd)) // call push on table for each construct
        */
        var evaluators = 0.evaluators
        for index in 0..<evaluators.count {
            let key = evaluators[index].displayName
            let taxEvent = TaxChangeEvent(gameState: gameState,
                                          genericOperator: evaluators[index],
                                          modifier: PresetConstants.taxModifiers[index])
            taxEvent.active = false
            neutralTaxEvents[key] = eventTable.pushEvent(
                event: taxEvent)
            /*itemPriceEvents[key] = [String: PresetEvent]()
            for item in ItemType.allCases {
                itemPriceEvents[key]?[item.rawValue] = eventTable.pushEvent(
                    event: ItemPriceEvent(gameState: gameState,
                                          itemType: item,
                                          genericOperator: evaluators[index],
                                          modifier: PresetConstants.priceModifers[index]))
            }*/
        }

        /*for player in gameState.getPlayers() {
            playerDeathEvents[player.name] = eventTable.pushEvent(
                event: NegativeMoneyEvent(player: player))
            _ = eventTable.pushEvent(event: PlayerArrivalEvent(player: player))
        }*/
        self.monsoonEvents = monsoonEvents
        self.neutralTaxEvents = neutralTaxEvents
        self.itemPriceEvents = itemPriceEvents
        self.playerDeathEvents = playerDeathEvents
    }
    func getEvent(event: Event) -> PresetEvent? {
        switch event {
        case .monsoon(activate: let activate):
            return monsoonEvents[activate]
        case .neutralTax(operand: let operand):
            return neutralTaxEvents[operand]
        case .itemPrice(for: let itemParameter, operand: let operand):
            return itemPriceEvents[operand]?[itemParameter.rawValue]
        case .playerDeath(for: let player):
            return playerDeathEvents[player.name]
        }
    }
    func getEvent(withId eventId: Int) -> PresetEvent? {
        return eventTable.getEvent(identifier: eventId)
    }
    func getEvents() -> [PresetEvent] {
        return eventTable.getAllEvents()
    }
}
