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
    let speedMultiplier = 1.0
    var node = NodeStub(name: "testNode", id: 0)
    var items = [GenericItemStub]()
    var suppliesConsumed = [GenericItemStub]()

    override func setUp() {
        super.setUp()
        node = NodeStub(name: "testNode", id: 0)

        items = [GenericItemStub]()
        let item1 = GenericItemStub(name: "TestItem1", itemType: .opium, quantity: 1)
        items.append(item1)

        suppliesConsumed = [GenericItemStub]()
        let consumed1 = GenericItemStub(name: "TestConsume1", itemType: .food, quantity: 1)
        suppliesConsumed.append(consumed1)
    }

    func testConstructor() {
        //init(node: Node, suppliesConsumed: [GenericItem])
        let ship = Ship(node: node, suppliesConsumed: suppliesConsumed)
        XCTAssertEqual(ship.nodeId, node.identifier)
        XCTAssertTrue(testTwoGenericItemArray(ship.suppliesConsumed, suppliesConsumed))
        XCTAssertEqual(ship.isChasedByPirates, false)
        XCTAssertEqual(ship.turnsToBeingCaught, 0)

        //subscribeToItems(with: updateCargoWeight)
        //shipObject = ShipUI(ship: self)
    }

    func testEncodeDecode() {
        let ship1 = Ship(node: node, suppliesConsumed: [])
        ship1.items.value = items
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
        XCTAssertTrue(testTwoGenericItemArray(ship1Decoded.suppliesConsumed, ship1.suppliesConsumed))
        XCTAssertEqual(ship1Decoded.shipChassis?.name,
                       ship1.shipChassis?.name)
        XCTAssertEqual(ship1Decoded.auxiliaryUpgrade?.name,
                       ship1.auxiliaryUpgrade?.name)
    }

    func testStartTurn() {
    }

    func testEndTurn() {
        //func endTurn(speedMultiplier: Double) -> [InfoMessage]
        let ship1 = Ship(node: node, suppliesConsumed: [])
        let pirateTimer1 = 10
        ship1.items.value = items
        ship1.isChasedByPirates = true
        ship1.turnsToBeingCaught = pirateTimer1
        let messages1 = ship1.endTurn(speedMultiplier: speedMultiplier)

        XCTAssertTrue(testTwoGenericItemArray(ship1.items.value, items))
        XCTAssertEqual(ship1.isChasedByPirates, true)
        XCTAssertEqual(ship1.turnsToBeingCaught, pirateTimer1 - 1)

        let ship2 = Ship(node: node, suppliesConsumed: [])
        ship2.items.value = items
        ship2.isChasedByPirates = true
        ship2.turnsToBeingCaught = 1
        let messages2 = ship2.endTurn(speedMultiplier: speedMultiplier)

        XCTAssertTrue(testTwoGenericItemArray(ship2.items.value, [GenericItem]()))
        XCTAssertEqual(ship2.isChasedByPirates, false)
        XCTAssertEqual(ship2.turnsToBeingCaught, 0)
        //messages.append(InfoMessage(title: "Pirates!", message: "You have been caught by pirates!. You lost all your cargo"))

        let ship3 = Ship(node: node, suppliesConsumed: suppliesConsumed)
        let money3 = 1000
        let owner3 = GenericPlayerStub()
        owner3.money.value = money3
        ship3.items.value = suppliesConsumed.map { $0.copy() }
        let messages3 = ship3.endTurn(speedMultiplier: speedMultiplier)

        XCTAssertTrue(testTwoGenericItemArray(ship3.items.value, [GenericItem]()))
        XCTAssertEqual(ship3.owner?.money.value, money3)

        //owner?.updateMoney(by: -deficit * parameter.getBuyValue())
        /*messages.append(InfoMessage(title: "deficit!",
                                    message: "You have exhausted \(parameter.displayName) and have a deficit of \(deficit) and paid for it."))*/

        // decay remaining items
        /*
        for item in items.value {
            guard let lostQuantity = item.decayItem(with: speedMultiplier) else {
                continue
            }
            messages.append(InfoMessage(title: "Lost Item",
                                        message: "You have lost \(lostQuantity) of \(item.itemParameter?.displayName ?? "") from decay and have \(item.quantity) remaining!"))
        }*/
    }

    override class func tearDown() {
        Node.nextID = 0
        Node.reuseID.removeAll()
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
}
