//
//  ItemTest.swift
//  SailingThroughHistoryTests
//
//  Created by ysq on 4/15/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ItemTest: XCTestCase {
    let cItemParameter = ItemParameter.food
    let uncItemParameter = ItemParameter.silk

    func testUpdateItem() {
        let item = Item(itemParameter: cItemParameter, quantity: 200)
        item.setQuantity(quantity: -100)
        XCTAssertEqual(item.quantity, 0, "Item quantity should not fall below 0.")
        item.setQuantity(quantity: 100)
        XCTAssertEqual(item.quantity, 100, "Item quantity is not successfully updated.")
    }

    func testCombine() {
        let cItemOneQ = 100
        let cItemTwoQ = 200
        let uncItemQ = 300
        let cItemSum = cItemOneQ + cItemTwoQ
        let cItemOne = Item(itemParameter: cItemParameter, quantity: cItemOneQ)
        let cItemTwo = Item(itemParameter: cItemParameter, quantity: cItemTwoQ)
        let uncItem = Item(itemParameter: uncItemParameter, quantity: uncItemQ)

        // test combine item - successfully
        var res = cItemOne.combine(with: cItemTwo)
        XCTAssertTrue(res, "Item with same ItemParameter should be combined.")
        XCTAssertEqual(cItemOne.quantity, cItemSum, "Item quantity is not successfuly combined.")
        XCTAssertEqual(cItemTwo.quantity, 0, "Item quantity is not successfuly combined.")

        // test combine item - fail
        res = cItemOne.combine(with: uncItem)
        XCTAssertFalse(res, "Item with different ItemParameter should not be combined.")
        XCTAssertEqual(cItemOne.quantity, cItemSum, "Item quantity should not be combined.")
        XCTAssertEqual(uncItem.quantity, uncItemQ, "Item quantity should not be combined.")
    }

    func testDecay() {
        let cItem = Item(itemParameter: cItemParameter, quantity: 100)
        // TODO:
    }

    func testRemove() {
        let item = Item(itemParameter: uncItemParameter, quantity: 100)

        // test remove without deficit
        var deficit = item.remove(amount: 50)
        XCTAssertEqual(item.quantity, 50, "Item quantity is not successfully updated with remove.")
        XCTAssertEqual(deficit, 0, "No deficit for removing with enough remaining quantity.")

        // test remove with deficit
        deficit = item.remove(amount: 100)
        XCTAssertEqual(item.quantity, 0,
                       "Item quantity is not successfully updated with remove. " +
            "Quantity should be 0 when there is not enough remaining quantity.")
        XCTAssertEqual(deficit, 50, "Deficit should be returned when removing without enough remaining quantity.")
    }

    func testBuy() {
        let price = 100
        let quantity = 100
        let item = Item(itemParameter: uncItemParameter, quantity: quantity)
        let port = SailingThroughHistory.Port(team: nil, name: "port", originX: 0, originY: 0)
        port.setBuyValue(of: uncItemParameter, value: price)
        let invPort = SailingThroughHistory.Port(team: nil, name: "port", originX: 0, originY: 0)

        // can buy item at port
        XCTAssertEqual(item.getBuyValue(at: port), price * quantity, "Get buy value returned false result.")

        XCTAssertEqual(item.getBuyValue(at: invPort), ItemParameter.defaultPrice * quantity,
                       "Get buy value returned false result.")
    }

    func testSell() {
        let price = 100
        let quantity = 100
        let item = Item(itemParameter: uncItemParameter, quantity: quantity)
        let port = SailingThroughHistory.Port(team: nil, name: "port", originX: 0, originY: 0)
        port.setBuyValue(of: uncItemParameter, value: price)
        let invPort = SailingThroughHistory.Port(team: nil, name: "port", originX: 0, originY: 0)

        // can sell item at port
        XCTAssertEqual(item.sell(at: port), price * quantity, "Get sell value returned false result.")

        XCTAssertEqual(item.sell(at: invPort), 0, "Wrong sell value returned.")
    }
}
