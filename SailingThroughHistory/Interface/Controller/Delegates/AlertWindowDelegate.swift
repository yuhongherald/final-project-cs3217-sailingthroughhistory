//
//  AlertWindowDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Delegate for AlertWindowController. Notified when the user acknowledges the message.
protocol AlertWindowDelegate: class {
    func acknoledgePressed()
}
