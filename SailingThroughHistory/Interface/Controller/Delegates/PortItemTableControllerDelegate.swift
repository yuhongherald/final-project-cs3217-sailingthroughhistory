//
//  PortItemTableControllerDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Delegate for PortItemTableController, notified when a user wishes to trade at the port.
protocol PortItemTableControllerDelegate: class {
    func portItemButtonPressed(action: PortItemButtonAction)
}
