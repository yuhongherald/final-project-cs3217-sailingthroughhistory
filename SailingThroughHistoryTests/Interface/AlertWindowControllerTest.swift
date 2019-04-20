//
//  AlertWindowControllerTest.swift
//  SailingThroughHistoryTests
//
//  Created by Jason Chong on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class AlertWindowControllerTest: XCTestCase {
    private let wrapper = UIView()
    private let message = UILabel()
    private let button = UIButton()
    private let delegate = DelegateStub() /// Strong reference needed to keep delegate in memory.
    private lazy var controller = AlertWindowController(delegate: delegate, wrapperView: wrapper,
                                                        messageView: message, buttonView: button)

    func testShow() {
        wrapper.isHidden = true
        controller.show(withMessage: "test")
        XCTAssertFalse(wrapper.isHidden, "Wrapper is not visible")
        XCTAssertEqual(message.text, "test", "Message is not correct")
        wrapper.isHidden = false
        controller.show(withMessage: "test")
        XCTAssertFalse(wrapper.isHidden, "Wrapper is not visible")
    }

    func funcButtonAction() {
        controller.buttonAction(sender: button)
        XCTAssertTrue(wrapper.isHidden, "Wrapper is visible after acknoledgement")
        XCTAssertTrue(delegate.acknowledged, "Not acknowledged")
    }

    func testHide() {
        wrapper.isHidden = true
        controller.hide()
        XCTAssertTrue(wrapper.isHidden, "Wrapper is not visible")
        wrapper.isHidden = false
        controller.hide()
        XCTAssertTrue(wrapper.isHidden, "Wrapper is not visible")
    }

    private class DelegateStub: AlertWindowDelegate {
        var acknowledged = false
        func acknoledgePressed() {
            acknowledged = true
        }
    }

}
