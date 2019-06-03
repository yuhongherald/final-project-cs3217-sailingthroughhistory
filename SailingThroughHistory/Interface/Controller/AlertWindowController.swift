//
//  AlertWindowController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Controller for the alert window that shows a message and an acknowledge button which dismisses it.
class AlertWindowController {
    private weak var delegate: AlertWindowDelegate?
    private weak var messageView: UILabel?
    private weak var buttonView: UIButton?
    private weak var wrapperView: UIView?

    /// Constructor for a controller that uses the input views and delegate to notify when the user has acknoledged the
    /// alert
    ///
    /// - Parameters:
    ///   - delegate: The delegate to notify.
    ///   - wrapperView: The wrapper view for the alert.
    ///   - messageView: The view to display the text message
    ///   - buttonView: The button to acknoledge the message
    init(delegate: AlertWindowDelegate, wrapperView: UIView, messageView: UILabel, buttonView: UIButton) {
        self.delegate = delegate
        self.messageView = messageView
        messageView.adjustsFontSizeToFitWidth = true
        self.buttonView = buttonView
        buttonView.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.wrapperView = wrapperView
    }

    /// Shows the alert window with the given message
    ///
    /// - Parameter message: The message to show in the window
    func show(withMessage message: String) {
        wrapperView?.isHidden = false
        messageView?.text = message
    }

    /// Hides the alert window.
    func hide() {
        wrapperView?.isHidden = true
    }

    /// Called when the acknowledge button is pressed. Hides the window and notifies the delegate of this event.
    ///
    /// - Parameter sender: The sender of this action.
    @objc func buttonAction(sender: UIButton?) {
        wrapperView?.isHidden = true
        delegate?.acknoledgePressed()
    }
}
