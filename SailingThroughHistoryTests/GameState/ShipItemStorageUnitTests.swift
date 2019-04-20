//
//  ShipItemStorageUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ShipItemStorageUnitTests: XCTestCase {
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
    func testGetPurchasableItemTypes() {
        //getPurchasableItemTypes() -> [ItemType]
    }

    func testGetMaxPurchaseAmount() {
        //func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int
    }

    func testBuyItem() {
        //func buyItem(itemType: ItemType, quantity: Int) throws
    }

    func testSellItem() {
        //func sellItem(item: GenericItem) throws
    }

    func testSell() {
        //func sell(itemType: ItemType, quantity: Int) throws
    }

    func testRemoveItem() {
        //func removeItem(by itemType: ItemType, with quantity: Int) -> Int
    }
}
