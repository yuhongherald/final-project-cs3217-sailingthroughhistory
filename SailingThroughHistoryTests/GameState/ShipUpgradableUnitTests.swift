//
//  ShipUpgradableUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ShipUpgradableUnitTests: XCTestCase {
    let node = NodeStub(name: "testNode", identifier: 0)
    let upgradeManager = ShipUpgradeManager()

    func testInstallUpgrade() {
        //func installUpgrade(upgrade: Upgrade) -> (Bool, InfoMessage?)
        var ship1: ShipAPI = Ship(node: node, itemsConsumed: [])
        let (bool1, msg1) = upgradeManager.installUpgrade(ship: &ship1, upgrade: BiggerShipUpgrade())
        guard let message1 = msg1 else {
            XCTFail("msg1 is nil")
            return
        }
        XCTAssertEqual(bool1, false)
        XCTAssertEqual(message1.getMessage(), InfoMessage.noOwner.getMessage())

        var ship2: ShipAPI = Ship(node: node, itemsConsumed: [])
        let owner2 = GenericPlayerStub()
        owner2.money.value = 0
        ship2.owner = owner2
        let (bool2, msg2) = upgradeManager.installUpgrade(ship: &ship2, upgrade: BiggerShipUpgrade())
        guard let message2 = msg2 else {
            XCTFail("msg2 is nil")
            return
        }
        XCTAssertEqual(bool2, false)
        XCTAssertEqual(message2.getMessage(), InfoMessage.cannotAfford(upgrade: BiggerShipUpgrade()).getMessage())

        var ship3: ShipAPI = Ship(node: node, itemsConsumed: [])
        ship3.shipChassis = BiggerShipUpgrade()
        let owner3 = GenericPlayerStub()
        owner3.money.value = 100000
        ship3.owner = owner3
        let (bool3, msg3) = upgradeManager.installUpgrade(ship: &ship3, upgrade: BiggerShipUpgrade())
        guard let message3 = msg3 else {
            XCTFail("msg3 is nil")
            return
        }
        XCTAssertEqual(bool3, false)
        XCTAssertEqual(message3.getMessage(), InfoMessage.duplicateUpgrade(type: "Ship Upgrade").getMessage())
        XCTAssertEqual(owner3.money.value, 100000)

        var ship4: ShipAPI = Ship(node: node, itemsConsumed: [])
        ship4.auxiliaryUpgrade = BiggerSailsUpgrade()
        let owner4 = GenericPlayerStub()
        owner4.money.value = 100000
        ship4.owner = owner4
        let (bool4, msg4) = upgradeManager.installUpgrade(ship: &ship4, upgrade: BiggerSailsUpgrade())
        guard let message4 = msg4 else {
            XCTFail("msg4 is nil")
            return
        }
        XCTAssertEqual(bool4, false)
        XCTAssertEqual(message4.getMessage(), InfoMessage.duplicateUpgrade(type: "Auxiliary Upgrade").getMessage())
        XCTAssertEqual(owner4.money.value, 100000)

        var ship5: ShipAPI = Ship(node: node, itemsConsumed: [])
        let owner5 = GenericPlayerStub()
        owner5.money.value = 100000
        ship5.owner = owner5
        let (bool5, msg5) = upgradeManager.installUpgrade(ship: &ship5, upgrade: BiggerSailsUpgrade())
        guard let message5 = msg5 else {
            XCTFail("msg5 is nil")
            return
        }
        XCTAssertEqual(bool5, true)
        XCTAssertEqual(message5.getMessage(), InfoMessage.upgradePurchased(upgrade: BiggerSailsUpgrade()).getMessage())
        XCTAssertEqual(owner5.money.value, 100000 - BiggerSailsUpgrade().cost)
        XCTAssertNotNil(ship5.auxiliaryUpgrade)
    }
}
