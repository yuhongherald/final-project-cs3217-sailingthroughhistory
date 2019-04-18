//
//  AlertWindowController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class AlertWindowController {
    private weak var delegate: AlertWindowDelegate?
    private weak var messageView: UILabel?
    private weak var buttonView: UIButton?
    private weak var wrapperView: UIView?

    init(delegate: AlertWindowDelegate, wrapperView: UIView, messageView: UILabel, buttonView: UIButton) {
        self.delegate = delegate
        self.messageView = messageView
        self.buttonView = buttonView
        buttonView.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.wrapperView = wrapperView
    }

    func show(withMessage message: String) {
        wrapperView?.isHidden = false
        messageView?.text = message
    }

    func hide() {
        wrapperView?.isHidden = true
    }

    @objc func buttonAction(sender: UIButton!) {
        wrapperView?.isHidden = true
        delegate?.acknoledgePressed()
    }
}
