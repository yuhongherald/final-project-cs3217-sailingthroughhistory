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
    static let itemParameters = [ItemParameter.opium, ItemParameter.food]
    static let team = Team(name: "testTeam")
    static let pirateNode = NodeStub(name: "pirateNode", identifier: 101)
    static let pirateIsland = PirateIsland(in: PlayerUnitTests.pirateNode)

    let item1 = Item(itemParameter: .opium, quantity: 1)
    let item2 = Item(itemParameter: .food, quantity: 1)
    var node = NodeStub(name: "testNode", identifier: 99)
    var node2 = NodeStub(name: "testNode2", identifier: 100)
    let port = Port(team: PlayerUnitTests.team, originX: 0.0, originY: 0.0)
    var map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
    var pirateMap = Map(map: "pirateMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
    let playerName = "testPlayer"
    let deviceName = "devName"

    override class func setUp() {
        PlayerUnitTests.pirateNode.add(object: PlayerUnitTests.pirateIsland)
    }

    override func setUp() {
        map.addNode(node)
        map.addNode(port)
        pirateMap.addNode(PlayerUnitTests.pirateNode)
    }

    override func tearDown() {
        map.removeNode(node)
        map.removeNode(port)
        pirateMap.removeNode(PlayerUnitTests.pirateNode)
        port.owner = nil
        port.taxAmount.value = 0
        Node.nextID = 0
        Node.reuseID.removeAll()
    }

    func testPlayerConstructor() {
        let player = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                            node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        XCTAssertEqual(player.name, player.name)
        XCTAssertEqual(player.team, PlayerUnitTests.team)
        XCTAssertTrue(player.map === map)
        XCTAssertEqual(player.deviceId, deviceName)
        XCTAssertEqual(player.homeNode, node.identifier)
        XCTAssertTrue(player.playerShip?.owner === player)
        XCTAssertEqual(player.money.value, 0)
        XCTAssertTrue(testTwoGenericItemArray(player.playerShip?.items.value ?? [GenericItem](), [item2]))
    }

    func testPlayerEncodeDecode() {
        let player = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                            node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        player.money.value = 1000

        guard let playerEncoded = try? JSONEncoder().encode(player) else {
            XCTFail("Encode failed")
            return
        }
        guard let playerDecoded = try? JSONDecoder().decode(Player.self, from: playerEncoded) else {
            XCTFail("Decode failed")
            return
        }
        XCTAssertEqual(playerDecoded.name, player.name)
        XCTAssertEqual(playerDecoded.team, PlayerUnitTests.team)
        XCTAssertNil(playerDecoded.map)
        XCTAssertEqual(playerDecoded.deviceId, deviceName)
        XCTAssertEqual(playerDecoded.homeNode, node.identifier)
        XCTAssertNotNil(playerDecoded.playerShip?.owner)
        XCTAssertEqual(playerDecoded.money.value, 1000)
        XCTAssertTrue(testTwoGenericItemArray(playerDecoded.playerShip?.items.value ?? [GenericItem](), [item2]))
    }

    func testUpdateMoney() {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        player1.money.value = 1000
        player1.updateMoney(to: 2000)
        XCTAssertEqual(player1.money.value, 2000)

        player1.updateMoney(by: -1000)
        XCTAssertEqual(player1.money.value, 1000)

        player1.updateMoney(by: 1)
        XCTAssertEqual(player1.money.value, 1001)

        player1.updateMoney(by: -10000)
        XCTAssertEqual(player1.money.value, 0)

        player1.updateMoney(to: -10000)
        XCTAssertEqual(player1.money.value, 0)
    }

    func testRoll() {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        player1.hasRolled = false
        let roll1 = player1.roll().0
        XCTAssertEqual(player1.hasRolled, true)
        XCTAssertEqual(player1.roll().0, roll1)
    }

    func testCanBuyUpgrade() throws {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        XCTAssertNotNil(player1.playerShip)
        XCTAssertEqual(player1.canBuyUpgrade(), false)
        try player1.dock()
        XCTAssertEqual(player1.canBuyUpgrade(), true)
    }

    func testGetPath() {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        player1.map = nil
        XCTAssertEqual(player1.getPath(to: node.identifier), [Int]())

        let player2 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: node, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        XCTAssertEqual(player2.getPath(to: node2.identifier), [Int]())
        XCTAssertEqual(player2.getPath(to: node.identifier), [node.identifier])
    }

    func testDock() throws {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        port.taxAmount.value = 1000
        port.owner = nil
        player1.money.value = 3000
        try player1.dock()
        XCTAssertEqual(player1.money.value, 2000)
    }

    func testGetPirateEncounterChance() {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)
        player1.map = nil
        XCTAssertEqual(player1.getPirateEncounterChance(at: node.identifier), 0)
        player1.map = map
        XCTAssertEqual(player1.getPirateEncounterChance(at: node2.identifier), 0)
        XCTAssertEqual(player1.getPirateEncounterChance(at: port.identifier), 0)
        XCTAssertEqual(player1.getPirateEncounterChance(at: node.identifier), map.basePirateRate)

        let player2 = Player(name: playerName, team: PlayerUnitTests.team, map: pirateMap,
                             node: PlayerUnitTests.pirateNode, itemsConsumed: [item1],
                             startingItems: [item2], deviceId: deviceName)
        XCTAssertEqual(player2.getPirateEncounterChance(at: PlayerUnitTests.pirateNode.identifier),
                       PlayerUnitTests.pirateIsland.chance)
        player2.money.value = 10000
        _ = player2.buyUpgrade(upgrade: MercernaryUpgrade())
        XCTAssertEqual(player2.getPirateEncounterChance(at: PlayerUnitTests.pirateNode.identifier), 0)
    }

    func testSetTax() throws {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [item1], startingItems: [item2], deviceId: deviceName)

        XCTAssertThrowsError(try player1.setTax(port: port, amount: 1)) { error in
            guard let exceedMaxTax = error as? PortAdminError else {
                XCTFail("Error was not correct type")
                return
            }
            XCTAssertEqual(exceedMaxTax.getMessage(), PortAdminError.exceedMaxTax(maxTaxAmount: 0).getMessage())
        }

        let gameParameter = GameParameter(map: map, teams: [PlayerUnitTests.team.name])
        let gameState = GameState(baseYear: 0, level: gameParameter, players: [])
        port.owner = player1.team
        player1.gameState = gameState

        XCTAssertThrowsError(try player1.setTax(port: port, amount: gameState.maxTaxAmount + 1)) { error in
                guard let exceedMaxTax = error as? PortAdminError else {
                    XCTFail("Error was not correct type")
                    return
                }
            XCTAssertEqual(exceedMaxTax.getMessage(),
                           PortAdminError.exceedMaxTax(maxTaxAmount: gameState.maxTaxAmount).getMessage())
        }

        XCTAssertThrowsError(try player1.setTax(port: port, amount: -1)) { error in
            guard let belowMinTax = error as? PortAdminError else {
                XCTFail("Error was not correct type")
                return
            }
            XCTAssertEqual(belowMinTax.getMessage(), PortAdminError.belowMinTax(minTaxAmount: 0).getMessage())
        }

        port.owner = player1.team
        try player1.setTax(port: port, amount: gameState.maxTaxAmount)
        XCTAssertEqual(port.taxAmount.value, gameState.maxTaxAmount)
        try player1.setTax(port: port, amount: 0)
        XCTAssertEqual(port.taxAmount.value, 0)

        port.owner = nil

        XCTAssertThrowsError(try player1.setTax(port: port, amount: 0)) { error in
            guard let badPortOwnership = error as? PortAdminError else {
                XCTFail("Error was not correct type")
                return
            }
            XCTAssertEqual(badPortOwnership.getMessage(), PortAdminError.badPortOwnership.getMessage())
        }
    }

    func testEndTurn() {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [], startingItems: [item2], deviceId: deviceName)
        player1.hasRolled = true
        player1.money.value = 3000
        port.taxAmount.value = 1000
        port.owner = nil
        XCTAssertEqual(player1.endTurn().map { $0.getMessage() }, [String]())
        XCTAssertEqual(player1.hasRolled, false)
        XCTAssertEqual(player1.money.value, 2000)
    }

    func testCanTradeAt() throws {
        let player1 = Player(name: playerName, team: PlayerUnitTests.team, map: map,
                             node: port, itemsConsumed: [], startingItems: [item2], deviceId: deviceName)
        XCTAssertEqual(player1.canTradeAt(port: port), false)
        try player1.dock()
        XCTAssertEqual(player1.canTradeAt(port: port), true)
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
