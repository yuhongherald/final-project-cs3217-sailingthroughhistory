//
//  ShipUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ShipUnitTests: XCTestCase {
    var node = NodeStub(name: "testNode", identifier: 0)
    var encodableItems = [Item]()
    var items = [GenericItemStub]()
    var itemsConsumed = [GenericItemStub]()
    var ports = [PortStub]()
    let map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
    private var wasItemSubscribeCalled = false

    override func setUp() {
        super.setUp()
        wasItemSubscribeCalled = false
        node = NodeStub(name: "testNode", identifier: 0)

        encodableItems = [Item]()
        let encodableItem1 = Item(itemParameter: .opium, quantity: 1)
        encodableItems.append(encodableItem1)

        items = [GenericItemStub]()
        let item1 = GenericItemStub(name: "TestItem1", itemParameter: .opium, quantity: 1)
        items.append(item1)

        itemsConsumed = [GenericItemStub]()
        let consumed1 = GenericItemStub(name: "TestConsume1", itemParameter: .food, quantity: 1)
        itemsConsumed.append(consumed1)

        ports = [PortStub]()
        let port1 = PortStub(buyValueOfAllItems: 100, sellValueOfAllItems: 100)
        ports.append(port1)

        for port in ports {
            map.addNode(port)
        }
    }

    override class func tearDown() {
        Node.nextID = 0
        Node.reuseID.removeAll()
    }

    override func tearDown() {
        for node in map.nodes.value {
            map.removeNode(node)
        }
    }

    func testConstructor() {
        let ship = Ship(node: node, itemsConsumed: itemsConsumed)
        XCTAssertEqual(ship.nodeId, node.identifier)
        XCTAssertTrue(testTwoGenericItemArray(ship.itemsConsumed, itemsConsumed))
        XCTAssertEqual(ship.isChasedByPirates, false)
        XCTAssertEqual(ship.turnsToBeingCaught, 0)

        ship.subscribeToItems(with: testSubscribeToItem)
        ship.items.value = []
        XCTAssertTrue(wasItemSubscribeCalled)
        guard let embeddedShip = ship.shipObject?.ship else {
            XCTFail("Ship object was not initialized correctly!")
            return
        }
        XCTAssertTrue(embeddedShip === ship)
    }

    func testEncodeDecode() {
        let ship1 = Ship(node: node, itemsConsumed: encodableItems)
        ship1.items.value = encodableItems
        let shipChassis = BiggerShipUpgrade()
        let auxiliaryUpgrade = MercernaryUpgrade()
        ship1.shipChassis = shipChassis
        ship1.auxiliaryUpgrade = auxiliaryUpgrade

        guard let ship1Encoded = try? JSONEncoder().encode(ship1) else {
            XCTFail("Encode failed")
            return
        }
        guard let ship1Decoded = try? JSONDecoder().decode(Ship.self, from: ship1Encoded) else {
            XCTFail("Decode failed")
            return
        }
        XCTAssertTrue(testTwoGenericItemArray(ship1Decoded.items.value, ship1.items.value))
        XCTAssertEqual(ship1Decoded.nodeId, ship1.nodeId)
        XCTAssertTrue(testTwoGenericItemArray(ship1Decoded.itemsConsumed, ship1.itemsConsumed))
        XCTAssertEqual(ship1Decoded.shipChassis?.name,
                       ship1.shipChassis?.name)
        XCTAssertEqual(ship1Decoded.auxiliaryUpgrade?.name,
                       ship1.auxiliaryUpgrade?.name)
    }

    func testStartTurn() {
    }

    func testEndTurn() {
        for num in 1...3 {
            let speedMultiplier = Double(num)
            let ship1 = Ship(node: node, itemsConsumed: [])
            let pirateTimer1 = 10
            ship1.items.value = items
            ship1.isChasedByPirates = true
            ship1.turnsToBeingCaught = pirateTimer1
            let messages1 = ship1.endTurn(speedMultiplier: speedMultiplier)

            XCTAssertTrue(testTwoGenericItemArray(ship1.items.value, items))
            XCTAssertEqual(ship1.isChasedByPirates, true)
            XCTAssertEqual(ship1.turnsToBeingCaught, pirateTimer1 - 1)
            XCTAssertEqual(infoMessagesToStrings(msgs: messages1), infoMessagesToStrings(msgs: [InfoMessage.pirates(turnsToBeingCaught: pirateTimer1 - 1)]))

            let ship2 = Ship(node: node, itemsConsumed: [])
            ship2.items.value = items
            ship2.isChasedByPirates = true
            ship2.turnsToBeingCaught = 1
            let messages2 = ship2.endTurn(speedMultiplier: speedMultiplier)

            XCTAssertTrue(testTwoGenericItemArray(ship2.items.value, [GenericItem]()))
            XCTAssertEqual(ship2.isChasedByPirates, false)
            XCTAssertEqual(ship2.turnsToBeingCaught, 0)
            XCTAssertEqual(infoMessagesToStrings(msgs: messages2), infoMessagesToStrings(msgs: [InfoMessage.caughtByPirates]))

            let ship3 = Ship(node: node, itemsConsumed: itemsConsumed)
            let money3 = 1000
            let owner3 = GenericPlayerStub()
            ship3.owner = owner3
            owner3.money.value = money3
            ship3.items.value = itemsConsumed.map {
                let item = $0.copy()
                item.quantity *= Int(speedMultiplier)
                return item
            }
            let messages3 = ship3.endTurn(speedMultiplier: speedMultiplier)

            XCTAssertTrue(testTwoGenericItemArray(ship3.items.value, [GenericItem]()))
            XCTAssertEqual(ship3.owner?.money.value, money3)
            XCTAssertEqual(infoMessagesToStrings(msgs: messages3), infoMessagesToStrings(msgs: [InfoMessage]()))

            let ship4 = Ship(node: node, itemsConsumed: itemsConsumed)
            let money4 = 1000
            let owner4 = GenericPlayerStub()
            ship4.owner = owner4
            owner4.money.value = money4
            owner4.map = map
            let messages4 = ship4.endTurn(speedMultiplier: speedMultiplier)

            XCTAssertTrue(testTwoGenericItemArray(ship4.items.value, [GenericItem]()))
            XCTAssertEqual(ship4.owner?.money.value, money4 - getTotalCostOfItemStubs(items: itemsConsumed) * Int(speedMultiplier) * 2)
            XCTAssertEqual(infoMessagesToStrings(msgs: messages4), infoMessagesToStrings(msgs: itemsConsumed.map {
                InfoMessage.deficit(itemName: $0.itemParameter.rawValue, deficit: $0.quantity * Int(speedMultiplier))
                }))
        }
    }

    private func testTwoGenericItemArray(_ array1: [GenericItem], _ array2: [GenericItem]) -> Bool {
        guard array1.count == array2.count else {
            return false
        }
        for (item1, item2) in zip(array1, array2) {
            guard item1 == item2 else {
                return false
            }
        }
        return true
    }

    private func testSubscribeToItem(items: [GenericItem]) {
        wasItemSubscribeCalled = true
    }

    private func infoMessagesToStrings(msgs: [InfoMessage]) -> [String] {
        var result = [String]()
        for msg in msgs {
            result.append(msg.getMessage())
        }
        return result
    }

    private func getTotalCostOfItemStubs(items: [GenericItemStub]) -> Int {
        var total = 0
        for item in items {
            total += item.itemParameter.getBuyValue(ports: ports)
        }
        return total
    }
}
