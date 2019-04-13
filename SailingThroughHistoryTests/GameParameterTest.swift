//
//  GameParameterTest.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/1/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class GameParameterTest: XCTestCase {
    func testUpdatePlayerParameter() {
        let originName = "name"
        let changedName = "changedName"

        // test update name and money
        let playerParameter = PlayerParameter(name: originName, teamName: "team", node: nil)
        playerParameter.set(name: changedName, money: 158)
        XCTAssertEqual(playerParameter.getName(), changedName, "Name is not successfully changed")
        XCTAssertEqual(playerParameter.getMoney(), 158, "Money is not successfully changed")
        XCTAssertTrue(playerParameter.getTeam() == Team(name: "team"), "Team is accidently changed")
    }

    func testCodablePlayerParameter() {
        // test without node
        var playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        guard let encode1 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        var decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode1)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with node
        playerParameter = PlayerParameter(name: "", teamName: "", node: Sea(name: "sea", originX: 1, originY: 100))
        guard let encode2 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode2)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with port
        playerParameter = PlayerParameter(name: "", teamName: "",
                                          node: Port(team: nil, name: "NPCport", originX: 0, originY: 0))
        guard let encode3 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode3)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        let team = Team(name: "team")
        let port = Port(team: team, name: "selfport", originX: 0, originY: 0)
        port.assignOwner(team)
        guard let encode4 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode4)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")
    }

    func testUpdateItemParameter() {
        // test valid update
        var itemParameter = ItemParameter(itemType: .opium, displayName: "Opium", weight: 100, isConsumable: true)
        itemParameter.setBuyValue(value: 1234)
        itemParameter.setSellValue(value: 5678)
        itemParameter.setHalfLife(to: 20)
        XCTAssertEqual(itemParameter.getBuyValue(), 1234, "BuyValue is not successfully updated.")
        XCTAssertEqual(itemParameter.getSellValue(), 5678, "SellValue is not successfully updated.")
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLift is not successfully updated.")

        // test invalid update
        itemParameter.setBuyValue(value: -1234)
        itemParameter.setSellValue(value: -5678)
        itemParameter.setHalfLife(to: -20)
        XCTAssertEqual(itemParameter.getBuyValue(), 1234, "BuyValue should not be updated to invalid value.")
        XCTAssertEqual(itemParameter.getSellValue(), 5678, "SellValue should not be updated to invalid value.")
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLift should not be updated to invalid value.")
    }

    func testCodableItemParameter() {
        let itemParameter = ItemParameter(itemType: .opium, displayName: "Opium", weight: 100, isConsumable: true)
        guard let encode = try? JSONEncoder().encode(itemParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(ItemParameter.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(itemParameter: decode, itemParameter), "Decode result is different from original one")
    }

    private func isEqual(playerParameter: PlayerParameter?, _ rhs: PlayerParameter) -> Bool {
        guard let lhs = playerParameter else {
            return false
        }
        return lhs.getName() == rhs.getName() && lhs.getTeam() == rhs.getTeam()
            && lhs.getMoney() == rhs.getMoney()
    }

    private func isEqual(node lhsNode: Node?, _ rhsNode: Node?) -> Bool {
        guard let lhs = lhsNode, let rhs = rhsNode else {
            return lhsNode == nil && rhsNode == nil
        }
        return lhs.frame == rhs.frame && lhs.name == rhs.name
    }

    private func isEqual(itemParameter: ItemParameter?, _ rhs: ItemParameter) -> Bool {
        guard let lhs = itemParameter else {
            return false
        }
        return lhs.getBuyValue() == rhs.getBuyValue() && lhs.getSellValue() == rhs.getSellValue()
            && lhs.getHalfLife() == rhs.getHalfLife() && lhs.displayName == rhs.displayName
            && lhs.isConsumable == rhs.isConsumable && lhs.unitWeight == rhs.unitWeight && lhs.itemType == rhs.itemType
    }
}
