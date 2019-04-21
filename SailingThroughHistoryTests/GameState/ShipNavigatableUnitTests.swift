//
//  ShipNavigatableUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ShipNavigatableUnitTests: XCTestCase {
    let centralNode = NodeStub(name: "centralTestNode", identifier: 99)
    let weatherStub = WeatherStub(windVelocity: 1.0)
    let navigationManager = ShipNavigationManager()
    var nodes1 = [NodeStub]()
    var nodes2 = [NodeStub]()
    var map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))

    override func setUp() {
        super.setUp()
        Node.nextID = 0
        Node.reuseID.removeAll()
        map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
        for ind in 0..<5 {
            let node1 = NodeStub(name: "testNode1 \(ind)", identifier: ind * 2)
            let node2 = NodeStub(name: "testNode2 \(ind)", identifier: ind * 2 + 1)
            nodes1.append(node1)
            nodes2.append(node2)
            map.addNode(node1)
            map.addNode(node2)
        }
        for ind in 0..<4 {
            map.add(path: Path(from: nodes1[ind], to: nodes1[ind + 1]))
            map.add(path: Path(from: nodes1[ind + 1], to: nodes1[ind]))
            map.add(path: Path(from: nodes2[ind], to: nodes2[ind + 1]))
            map.add(path: Path(from: nodes2[ind + 1], to: nodes2[ind]))
        }
        map.addNode(centralNode)
        var centralPaths = [Path]()
        centralPaths.append(Path(from: nodes1[0], to: centralNode))
        centralPaths.append(Path(from: centralNode, to: nodes1[0]))
        centralPaths.append(Path(from: nodes2[0], to: centralNode))
        centralPaths.append(Path(from: centralNode, to: nodes2[0]))
        for ind in 0..<centralPaths.count {
            map.add(path: centralPaths[ind])
            centralPaths[ind].modifiers.append(weatherStub)
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

    func testGetNodesInRange() {
        let ship1 = Ship(node: centralNode, itemsConsumed: [])
        ship1.map = map
        XCTAssertEqual(navigationManager.getNodesInRange(ship: ship1, roll: 1, speedMultiplier: 1.0), [centralNode])
        for roll in 2...6 {
            var nodesInRange = [centralNode]
            for ind in 0..<(roll - 1) {
                nodesInRange.append(nodes1[ind])
                nodesInRange.append(nodes2[ind])
            }
            XCTAssertEqual(Set(navigationManager.getNodesInRange(ship: ship1, roll: roll, speedMultiplier: 1.0)), Set(nodesInRange))
        }
        for roll in 1...3 {
            let bound = roll * 2 - 2
            var nodesInRange = [centralNode]
            for ind in 0...bound {
                nodesInRange.append(nodes1[ind])
                nodesInRange.append(nodes2[ind])
            }
            XCTAssertEqual(Set(navigationManager.getNodesInRange(ship: ship1, roll: roll, speedMultiplier: 2.0)), Set(nodesInRange))
        }

        let ship2 = Ship(node: centralNode, itemsConsumed: [])
        ship2.auxiliaryUpgrade = BiggerSailsUpgrade()
        ship2.map = map
        XCTAssertEqual(navigationManager.getNodesInRange(ship: ship2, roll: 1, speedMultiplier: 1.0), [centralNode])
        for roll in 2...6 {
            var nodesInRange = [centralNode]
            for ind in 0..<(roll - 1) {
                nodesInRange.append(nodes1[ind])
                nodesInRange.append(nodes2[ind])
            }
            XCTAssertEqual(Set(navigationManager.getNodesInRange(ship: ship2, roll: roll, speedMultiplier: 1.0)), Set(nodesInRange))
        }

        let ship3 = Ship(node: centralNode, itemsConsumed: [])
        ship3.shipChassis = FasterShipUpgrade()
        ship3.map = map
        for roll in 1...3 {
            let bound = Int(Double(roll) * FasterShipUpgrade().getMovementModifier() - 2)
            var nodesInRange = [centralNode]
            for ind in 0...bound {
                nodesInRange.append(nodes1[ind])
                nodesInRange.append(nodes2[ind])
            }
            XCTAssertEqual(Set(navigationManager.getNodesInRange(ship: ship3, roll: roll, speedMultiplier: 1.0)), Set(nodesInRange))
        }
    }

    func testMove() {
        guard let endNode = nodes1.last else {
            XCTFail("No nodes in Navigation test")
            return
        }
        var ship1: ShipAPI = Ship(node: centralNode, itemsConsumed: [])
        ship1.map = map
        ship1.shipObject = nil
        ship1.isDocked = true
        navigationManager.move(ship: &ship1, node: endNode)
        XCTAssertEqual(ship1.isDocked, true)
        XCTAssertEqual(ship1.nodeId, centralNode.identifier)

        var ship2: ShipAPI = Ship(node: centralNode, itemsConsumed: [])
        ship2.map = map
        ship2.isDocked = true
        navigationManager.move(ship: &ship2, node: endNode)
        XCTAssertEqual(ship2.isDocked, true)
        XCTAssertEqual(ship2.nodeId, endNode.identifier)
    }

    func testCanDock() {
        Node.nextID = 1000
        let port = PortStub()
        map.addNode(port)

        let ship1: ShipAPI = Ship(node: centralNode, itemsConsumed: [])
        XCTAssertEqual(navigationManager.canDock(ship: ship1), false)

        var ship2: ShipAPI = Ship(node: centralNode, itemsConsumed: [])
        ship2.map = map
        XCTAssertEqual(navigationManager.canDock(ship: ship2), false)

        var ship3: ShipAPI = Ship(node: port, itemsConsumed: [])
        ship3.map = map
        XCTAssertEqual(navigationManager.canDock(ship: ship3), true)

        map.removeNode(port)
        Node.nextID = 0
        Node.reuseID.removeAll()
    }

    func testDock() throws {
        Node.nextID = 1000
        let port = PortStub()
        map.addNode(port)
        let team = Team(name: "testTeam")
        port.owner = team

        //func dock() throws -> Port
        var ship1: ShipAPI = Ship(node: centralNode, itemsConsumed: [])
        ship1.isDocked = false
        ship1.isChasedByPirates = true
        ship1.turnsToBeingCaught = 1
        XCTAssertEqual(navigationManager.canDock(ship: ship1), false)
        XCTAssertThrowsError(try navigationManager.dock(ship: &ship1)) { error in
                guard let unableToDock = error as? MovementError else {
                    XCTFail("Error was not correct type")
                    return
                }
                XCTAssertEqual(unableToDock.getMessage(), MovementError.unableToDock.getMessage())
        }
        XCTAssertEqual(ship1.isDocked, false)
        XCTAssertEqual(ship1.isChasedByPirates, true)
        XCTAssertEqual(ship1.turnsToBeingCaught, 1)

        port.taxAmount.value = 1000
        port.owner = team
        team.money.value = 0
        var ship2: ShipAPI = Ship(node: port, itemsConsumed: [])
        ship2.map = map
        ship2.isDocked = false
        ship2.isChasedByPirates = true
        ship2.turnsToBeingCaught = 1
        XCTAssertEqual(navigationManager.canDock(ship: ship2), true)
        XCTAssertEqual(try navigationManager.dock(ship: &ship2), port)
        XCTAssertEqual(ship2.isDocked, true)
        XCTAssertEqual(ship2.isChasedByPirates, false)
        XCTAssertEqual(ship2.turnsToBeingCaught, 0)
        XCTAssertEqual(team.money.value, port.taxAmount.value)

        map.removeNode(port)
        Node.nextID = 0
        Node.reuseID.removeAll()
    }
}
