//
//  ObjectsViewControllerTest.swift
//  SailingThroughHistoryTests
//
//  Created by Jason Chong on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class ObjectsViewControllerTest: XCTestCase {
    private let map = Map(map: "test", bounds: Rect(originX: 0, originY: 0, height: 1000, width: 1000))
    private let bounds = CGRect(fromRect: Rect(originX: 0, originY: 0, height: 100, width: 100))
    private let delegate = DelegateStub()
    private lazy var controller = ObjectsViewController(view: view, modelBounds: map.bounds, delegate: delegate)
    private lazy var view = UIView(frame: bounds)
    private let port = PortStub(team: nil, name: "port1", originX: 10, originY: 10)

    func testSubscribeNodes() {
        controller.subscribeToNodes(in: map)
        XCTAssertTrue(view.subviews.isEmpty, "Views added on subscription to empty map")
        map.addNode(port)
        XCTAssertEqual(view.subviews.count, 1, "Node not added properly")
        let height = port.frame.height
        let width = port.frame.width
        XCTAssertEqual(view.subviews[0].frame, CGRect(x: 1, y: 1, width: width / 10, height: height / 10))
        map.removeNode(port)
        XCTAssertTrue(view.subviews.isEmpty, "Node not removed properly")
    }

    func testSubscribeObjects() {
        controller.subscribeToObjects(in: map)
        XCTAssertTrue(view.subviews.isEmpty, "Views added on subscription to empty map")
        let object = GameObject(frame: Rect(originX: 10, originY: 10, height: 100, width: 100))
        map.addGameObject(gameObject: object)
        XCTAssertEqual(view.subviews.count, 1, "Object not added properly")
        XCTAssertEqual(view.subviews[0].frame, CGRect(x: 1, y: 1, width: 10, height: 10))
        object.set(frame: Rect(originX: 1, originY: 1, height: 100, width: 100))
        XCTAssertEqual(view.subviews[0].frame, CGRect(x: 0.1, y: 0.1, width: 10, height: 10))
    }

    func testTap() {
        let view = NodeView(node: port)
        XCTAssertEqual(controller.onTap(nodeView: view), port.identifier, "Wrong identifier returned")
        XCTAssertEqual(delegate.shownPort, port, "Information not shown for port tapped.")
    }

    private class DelegateStub: ObjectsViewControllerDelegate {
        var shownPort: SailingThroughHistory.Port?

        init() {
            shownPort = nil
        }

        func showInformation(of port: SailingThroughHistory.Port) {
            shownPort = port
        }
    }
}
