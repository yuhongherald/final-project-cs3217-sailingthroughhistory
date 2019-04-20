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
    static let itemParameters = [ItemParameter.opium, ItemParameter.food]

    var node = NodeStub(name: "testNode", identifier: 0)
    var items = ShipItemStorageUnitTests.itemParameters.map {
        GenericItemStub(name: $0.rawValue, itemParameter: $0, quantity: 1)
    }

    let portWithItems = PortStub(buyValueOfAllItems: 100, sellValueOfAllItems: 100, itemParameters: ShipItemStorageUnitTests.itemParameters)
    let portWithoutItems = PortStub(buyValueOfAllItems: 100, sellValueOfAllItems: 100, itemParameters: [])
    let itemStorage = ShipItemManager()
    var map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))

    override func setUp() {
        super.setUp()
        node = NodeStub(name: "testNode", identifier: 0)
        map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
        map.addNode(node)
        map.addNode(portWithItems)
        map.addNode(portWithoutItems)
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
        let ship1 = Ship(node: portWithItems, itemsConsumed: [])
        ship1.isDocked = true
        ship1.map = map
        let itemParameters1 = itemStorage.getPurchasableItemParameters(ship: ship1)

        XCTAssertEqual(Set(itemParameters1), Set(ShipItemStorageUnitTests.itemParameters))

        let ship2 = Ship(node: node, itemsConsumed: [])
        ship2.isDocked = true
        ship2.map = map
        let itemParameters2 = itemStorage.getPurchasableItemParameters(ship: ship2)

        XCTAssertEqual(itemParameters2, [ItemParameter]())
    }

    func testGetMaxPurchaseAmount() {
        guard let itemParameter = ShipItemStorageUnitTests.itemParameters.first else {
            XCTFail("No item parameters defined for ItemStorage tests")
            return
        }
        let ship1 = Ship(node: portWithItems, itemsConsumed: [])
        ship1.map = map
        ship1.isDocked = true
        ship1.weightCapacity = 100000
        let owner1 = GenericPlayerStub()
        owner1.money.value = 1000
        ship1.owner = owner1
        let amount1 = itemStorage.getMaxPurchaseAmount(ship: ship1, itemParameter: itemParameter)
        guard let portValue1 = portWithItems.getBuyValue(of: itemParameter) else {
            XCTFail("Item not sold at port!")
            return
        }

        XCTAssertEqual(amount1, owner1.money.value / portValue1)

        let ship2 = Ship(node: portWithItems, itemsConsumed: [])
        ship2.map = map
        ship2.isDocked = true
        ship2.weightCapacity = 1000
        let owner2 = GenericPlayerStub()
        owner2.money.value = 100000
        ship2.owner = owner2
        let amount2 = itemStorage.getMaxPurchaseAmount(ship: ship2, itemParameter: itemParameter)

        XCTAssertEqual(amount2, ship2.weightCapacity / itemParameter.unitWeight)

        let ship3 = Ship(node: node, itemsConsumed: [])
        ship3.map = map
        ship3.isDocked = true
        ship3.weightCapacity = 100000
        let owner3 = GenericPlayerStub()
        owner3.money.value = 100000
        ship3.owner = owner3
        let amount3 = itemStorage.getMaxPurchaseAmount(ship: ship3, itemParameter: itemParameter)

        XCTAssertEqual(amount3, 0)

        let ship4 = Ship(node: node, itemsConsumed: [])
        ship4.map = map
        ship4.isDocked = true
        ship4.weightCapacity = 100000
        let amount4 = itemStorage.getMaxPurchaseAmount(ship: ship4, itemParameter: itemParameter)

        XCTAssertEqual(amount4, 0)
    }

    func testBuyItem() throws {
        guard let itemParameter = ShipItemStorageUnitTests.itemParameters.first else {
            XCTFail("No item parameters defined for ItemStorage tests")
            return
        }
        guard let itemValue = portWithItems.getBuyValue(of: itemParameter) else {
            XCTFail("Item not available at port!")
            return
        }
        for quantity in 1...3 {
            let ship1 = Ship(node: node, itemsConsumed: [])
            ship1.weightCapacity = 100000
            ship1.map = map
            ship1.isDocked = true
            let owner1 = GenericPlayerStub()
            owner1.money.value = 100000
            ship1.owner = owner1

            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship1,
                     itemParameter: itemParameter, quantity: quantity)) { error in
                guard let notDockedError = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(notDockedError.getMessage(), TradeItemError.notDocked.getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship1.items.value, [GenericItem]()))

            let ship2 = Ship(node: portWithoutItems, itemsConsumed: [])
            ship2.weightCapacity = 100000
            ship2.map = map
            ship2.isDocked = true
            let owner2 = GenericPlayerStub()
            owner2.money.value = 100000
            ship2.owner = owner2
            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship2,
                         itemParameter: itemParameter, quantity: quantity)) { error in
                guard let itemNotAvailableError = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(itemNotAvailableError.getMessage(), TradeItemError.itemNotAvailable.getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship2.items.value, [GenericItem]()))

            let ship3 = Ship(node: portWithItems, itemsConsumed: [])
            ship3.weightCapacity = 100000
            ship3.map = map
            ship3.isDocked = true
            let owner3 = GenericPlayerStub()
            owner3.money.value = 0
            ship3.owner = owner3
            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship3,
                     itemParameter: itemParameter, quantity: quantity)) { error in
                guard let insufficientFunds = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(insufficientFunds.getMessage(),
                   TradeItemError.insufficientFunds(shortOf: itemValue * quantity - owner3.money.value).getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship3.items.value, [GenericItem]()))
        }
    }

    func testBuyItem2() throws {
        guard let itemParameter = ShipItemStorageUnitTests.itemParameters.first else {
            XCTFail("No item parameters defined for ItemStorage tests")
            return
        }
        guard let itemValue = portWithItems.getBuyValue(of: itemParameter) else {
            XCTFail("Item not available at port!")
            return
        }
        let item = Item(itemParameter: itemParameter, quantity: 1)
        for quantity in 1...3 {
            let ship4 = Ship(node: portWithItems, itemsConsumed: [])
            ship4.weightCapacity = 100000
            ship4.isDocked = true
            ship4.map = map
            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship4,
                 itemParameter: itemParameter, quantity: quantity)) { error in
                guard let insufficientFunds = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(insufficientFunds.getMessage(),
                   TradeItemError.insufficientFunds(shortOf: itemValue * quantity).getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship4.items.value, [GenericItem]()))

            let ship5 = Ship(node: portWithItems, itemsConsumed: [])
            ship5.weightCapacity = itemParameter.unitWeight * quantity - 1
            ship5.isDocked = true
            ship5.map = map
            let owner5 = GenericPlayerStub()
            owner5.money.value = 100000
            ship5.owner = owner5
            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship5,
                     itemParameter: itemParameter, quantity: quantity)) { error in
                guard let insufficientCapacity = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(insufficientCapacity.getMessage(),
                   TradeItemError.insufficientCapacity(shortOf: itemParameter.unitWeight * quantity - ship5.weightCapacity).getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship5.items.value, [GenericItem]()))

            let ship6 = Ship(node: portWithItems, itemsConsumed: [])
            ship6.weightCapacity = itemParameter.unitWeight * quantity
            ship6.isDocked = true
            ship6.map = map
            ship6.items.value = [item.copy()]
            let owner6 = GenericPlayerStub()
            owner6.money.value = 100000
            ship6.owner = owner6
            XCTAssertThrowsError(try itemStorage.buyItem(ship: ship6,
                     itemParameter: itemParameter, quantity: quantity)) { error in
                guard let insufficientCapacity = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(insufficientCapacity.getMessage(),
                   TradeItemError.insufficientCapacity(shortOf: -itemParameter.unitWeight * quantity + ship6.weightCapacity + item.weight).getMessage())
            }
            XCTAssertTrue(testTwoGenericItemArray(ship6.items.value, [item]))

            let ship7 = Ship(node: portWithItems, itemsConsumed: [])
            ship7.weightCapacity = 100000
            ship7.isDocked = true
            ship7.map = map
            ship7.items.value = [item.copy()]
            let owner7 = GenericPlayerStub()
            owner7.money.value = 100000
            ship7.owner = owner7
            try itemStorage.buyItem(ship: ship7, itemParameter: itemParameter, quantity: quantity)
            let combinedItem = Item(itemParameter: itemParameter, quantity: quantity + item.quantity)
            XCTAssertTrue(testTwoGenericItemArray(ship7.items.value, [combinedItem]))
            XCTAssertEqual(owner7.money.value, 100000 - quantity * itemValue)
        }
    }

    func testSellItem() throws {
        guard let itemParameter = ShipItemStorageUnitTests.itemParameters.first else {
            XCTFail("No item parameters defined for ItemStorage tests")
            return
        }
        guard let itemValue = portWithItems.getBuyValue(of: itemParameter) else {
            XCTFail("Item not available at port!")
            return
        }
        let item = Item(itemParameter: itemParameter, quantity: 1)
        let quantity = item.quantity + 1

        //func sellItem(item: GenericItem) throws
        let ship1 = Ship(node: node, itemsConsumed: [])
        ship1.weightCapacity = 100000
        ship1.map = map
        ship1.items.value = [item.copy()]
        ship1.isDocked = true
        let owner1 = GenericPlayerStub()
        owner1.money.value = 0
        ship1.owner = owner1

        XCTAssertThrowsError(try itemStorage.sell(ship: ship1,
             itemParameter: itemParameter, quantity: item.quantity)) { error in
                guard let notDockedError = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(notDockedError.getMessage(), TradeItemError.notDocked.getMessage())
        }
        XCTAssertTrue(testTwoGenericItemArray(ship1.items.value, [item]))

        let ship2 = Ship(node: portWithoutItems, itemsConsumed: [])
        ship2.weightCapacity = 100000
        ship2.map = map
        ship2.items.value = [item.copy()]
        ship2.isDocked = true
        let owner2 = GenericPlayerStub()
        owner2.money.value = 0
        ship2.owner = owner2

        XCTAssertThrowsError(try itemStorage.sell(ship: ship2,
              itemParameter: itemParameter, quantity: item.quantity)) { error in
                guard let itemNotAvailable = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(itemNotAvailable.getMessage(), TradeItemError.itemNotAvailable.getMessage())
        }
        XCTAssertTrue(testTwoGenericItemArray(ship2.items.value, [item]))

        let ship3 = Ship(node: portWithItems, itemsConsumed: [])
        ship3.weightCapacity = 100000
        ship3.map = map
        ship3.items.value = [item.copy()]
        ship3.isDocked = true
        let owner3 = GenericPlayerStub()
        owner3.money.value = 0
        ship3.owner = owner3

        try itemStorage.sell(ship: ship3, itemParameter: itemParameter, quantity: item.quantity)
        XCTAssertTrue(testTwoGenericItemArray(ship3.items.value, [GenericItem]()))
        XCTAssertEqual(owner3.money.value, item.quantity * itemValue)

        let ship4 = Ship(node: portWithItems, itemsConsumed: [])
        ship4.weightCapacity = 100000
        ship4.map = map
        ship4.items.value = [item.copy()]
        ship4.isDocked = true
        let owner4 = GenericPlayerStub()
        owner4.money.value = 0
        ship4.owner = owner4

        XCTAssertThrowsError(try itemStorage.sell(ship: ship4,
              itemParameter: itemParameter, quantity: quantity)) { error in
                guard let insufficientItems = error as? TradeItemError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(insufficientItems.getMessage(), TradeItemError.insufficientItems(shortOf: quantity - item.quantity, sold: item.quantity).getMessage())
        }
        XCTAssertTrue(testTwoGenericItemArray(ship4.items.value, [GenericItem]()))
        XCTAssertEqual(owner4.money.value, item.quantity * itemValue)
    }

    func testRemoveItem() {
        guard let itemParameter1 = ShipItemStorageUnitTests.itemParameters.first,
            let itemParameter2 = ShipItemStorageUnitTests.itemParameters.last,
            itemParameter1 != itemParameter2 else {
            XCTFail("One or less item parameters defined for ItemStorage tests")
            return
        }
        let item1 = Item(itemParameter: itemParameter1, quantity: 1)
        let item2 = Item(itemParameter: itemParameter2, quantity: 1)
        let item1More = Item(itemParameter: itemParameter1, quantity: 2)

        //func removeItem(by itemType: ItemType, with quantity: Int) -> Int
        let ship1 = Ship(node: node, itemsConsumed: [])
        ship1.items.value = [item1.copy()]
        XCTAssertEqual(itemStorage.removeItem(ship: ship1, by: itemParameter2, with: 1), 1)
        XCTAssertTrue(testTwoGenericItemArray(ship1.items.value, [item1]))

        let ship2 = Ship(node: node, itemsConsumed: [])
        ship2.items.value = [item1.copy()]
        XCTAssertEqual(itemStorage.removeItem(ship: ship2, by: itemParameter1, with: 1), 0)
        XCTAssertTrue(testTwoGenericItemArray(ship2.items.value, [GenericItemStub]()))

        let ship3 = Ship(node: node, itemsConsumed: [])
        ship3.items.value = [item1More.copy()]
        XCTAssertEqual(itemStorage.removeItem(ship: ship3, by: itemParameter1, with: 1), 0)
        XCTAssertTrue(testTwoGenericItemArray(ship3.items.value, [item1]))

        let ship4 = Ship(node: node, itemsConsumed: [])
        ship4.items.value = [item1.copy()]
        XCTAssertEqual(itemStorage.removeItem(ship: ship4, by: itemParameter1, with: 2), 1)
        XCTAssertTrue(testTwoGenericItemArray(ship4.items.value, [GenericItemStub]()))

        let ship5 = Ship(node: node, itemsConsumed: [])
        ship5.items.value = [item1.copy(), item1.copy()]
        XCTAssertEqual(itemStorage.removeItem(ship: ship5, by: itemParameter1, with: 2), 0)
        XCTAssertTrue(testTwoGenericItemArray(ship5.items.value, [GenericItemStub]()))
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
