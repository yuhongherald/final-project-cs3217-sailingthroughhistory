//
//  NPCUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest

class NPCUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNPCConstructor() {
    }

    func testNPCEncodeDecode() {
    }

    func testNPCMoveToNextNode() {
        /*
        func moveToNextNode(map: Map, maxTaxAmount: Int) -> Node? {
            let nextNodeId = getNextNode(map: map, maxTaxAmount: maxTaxAmount)
            guard let currentNode = map.nodeIDPair[nodeId], let nextNode = map.nodeIDPair[nodeId] else {
                return nil
            }
            nodeId = nextNodeId
            let path = currentNode.getCompleteShortestPath(to: nextNode, with: self, map: map)
            for node in path {
                frame.value = node.frame
            }
            frame.value = nextNode.frame
            if let port = nextNode as? Port {
                port.collectTax(from: self)
            }
            return nextNode
        }*/
    }

    func testGetNextNode() {
        /*func getNextNode(map: Map, maxTaxAmount: Int) -> Int {
         var generator = GKMersenneTwisterRandomSource()
         generator.seed = UInt64(nextSeed)
         if nextDestinationId == nodeId {
         nextDestinationId = getNewDestinationPortId(generator: &generator, map: map)
         }
         guard let currentNode = map.nodeIDPair[nodeId] else {
         fatalError("NPC ship is in invalid node")
         }
         guard let destinationNode = map.nodeIDPair[nextDestinationId] else {
         fatalError("NPC ship has invalid destination node")
         }
         let path = currentNode.getCompleteShortestPath(to: destinationNode, with: self, map: map)
         let movementRoll = 1 + generator.nextInt(upperBound: numDieSides)

         if movementRoll >= path.count - 1 {
         nextSeed = UInt(generator.nextInt(upperBound: Int.max))
         return nextDestinationId
         }
         let selectedPorts = Array(path[0..<movementRoll]).map({ $0 as? Port }).compactMap({ $0 })
         var lowestTax = maxTaxAmount
         var lowestTaxPort = selectedPorts.first
         for port in selectedPorts {
         lowestTax = min(lowestTax, port.taxAmount.value)
         lowestTaxPort = port
         }

         let decidingRoll = generator.nextUniform()
         nextSeed = UInt(generator.nextInt(upperBound: Int.max))
         if decidingRoll > Float(lowestTax) / Float(maxTaxAmount),
         let lowestTaxPortId = lowestTaxPort?.identifier {
         return lowestTaxPortId
         }
         return path[movementRoll - 1].identifier
         }*/
    }

}
