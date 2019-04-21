//
//  PlayerUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class PlayerUnitTests: XCTestCase {
    var node = NodeStub(name: "testNode", identifier: 99)
    let team = Team(name: "testTeam")
    let playerName = "testPlayer"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlayerConstructor() {
        /*
        init(name: String, team: Team, map: Map, node: Node, itemsConsumed: [GenericItem],
        startingItems: [GenericItem], deviceId: String) {
            self.name = name
            self.team = team
            self.map = map
            self.deviceId = deviceId
            self.homeNode = node.identifier
            ship = Ship(node: node, itemsConsumed: itemsConsumed)
            ship.owner = self
            ship.map = map
            ship.items.value.append(contentsOf: startingItems)
            ship.updateCargoWeight(items: ship.items.value)
        }*/
    }

    func testPlayerEncodeDecode() {
    }

    func testUpdateMoney() {
/* func updateMoney(to amount: Int)
 func updateMoney(by amount: Int)*/
    }

    func testCanBuyUpgrade() {
    }

    func testStartTurn() {
    }

    func testBuyUpgrade() {
    }

    func testRoll() {
    }

    func testMove() {
    }

    func testGetPath() {
    }

    func testGetNodesInRange() {
    }

    func testCanDock() {
    }

    func testDock() {
    }

    func testGetPirateEncounterChange() {
    }

    func testGetPurchasableItemParameters() {
    }

    func testGetMaxPurchaseAmount() {
    }

    func testBuy() {
    }

    func testSell() {
        /*
 func sell(item: GenericItem) throws
 func sell(itemParameter: ItemParameter, quantity: Int) throws
*/
    }

    func testSetTax() {
    }

    func testEndTurn() {
    }

    func testCanTradeAt() {
    }

    func testMoneyBelowZero() {
    }
}
